import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Notepad } from '../types'

const PLUGIN = 'session-notepad'
const PANE = 'notepad'
const TOOL = 'notepad'
const TOOL_FULL = `mcp__${PLUGIN}__${TOOL}`

const notepad = atom(
  { plugin: 'session-notepad', key: 'notepad' } as const,
  { nextId: 1, items: [] },
  { shape: 'notepad-3' },
)

const KEEP_SESSIONS = 100
const storeKey = (sessionId: string) => `pad:${sessionId}`

const sync = async ($: EngineInterface): Promise<Notepad> => {
  const sessionId = await $.session.id()
  const current = await read($, notepad)
  if (current.sessionId === sessionId) {
    return current
  }
  const saved = (await $.store.get(storeKey(sessionId))) as Saved | undefined
  const items = (saved?.items ?? [])
    .filter(i => !i.isDone)
    .map(({ id, text }) => ({ id, text }))

  return update($, notepad, () => ({ nextId: saved?.nextId ?? 1, items, sessionId }))
}

const change = async ($: EngineInterface, ops: Ops): Promise<Notepad> => {
  await sync($)
  const pad = await update($, notepad, p => apply(p, ops))
  if (pad.sessionId !== undefined) {
    await $.store.set(storeKey(pad.sessionId), { nextId: pad.nextId, items: pad.items })
    const keys = await $.store.keys()
    for (const key of keys.slice(0, Math.max(0, keys.length - KEEP_SESSIONS))) {
      await $.store.delete(key)
    }
  }

  return pad
}

type Saved = { nextId: number; items: { id: number; text: string; isDone?: boolean }[] }

type Ops = {
  add?: string[]
  done?: number[]
  remove?: number[]
  edit?: { id: number; text: string }[]
}

const apply = (pad: Notepad, ops: Ops): Notepad => {
  let { nextId, items } = pad
  for (const text of ops.add ?? []) {
    const clean = text.trim()
    if (clean !== '' && !items.some(i => i.text === clean)) {
      items = [...items, { id: nextId++, text: clean }]
    }
  }
  const gone = new Set([...(ops.done ?? []), ...(ops.remove ?? [])])
  const edits = new Map((ops.edit ?? []).map(e => [e.id, e.text.trim()]))
  items = items
    .filter(i => !gone.has(i.id))
    .map(i => ({ ...i, text: edits.get(i.id) || i.text }))

  return { ...pad, nextId, items }
}

const format = (pad: Notepad): string =>
  pad.items.length === 0
    ? 'Notepad is empty.'
    : pad.items.map(i => `#${i.id} ${i.text}`).join('\n')

const INSTRUCTIONS = `A pane beside the chat shows a per-session notepad: a short bullet list of small pending items the person must not lose as output scrolls (things to test, check, verify, try, follow up on). Keep it current with this tool, without being asked:
- add an item whenever you or the person mention something still to test, check or do later, one short line each, in the person's language
- mark items done as soon as they are verified or no longer relevant (done items are removed), edit them when they change
- do not add the task currently being worked on, nor anything already listed
The tool answers with the full list; read it rather than guessing ids.`

const USAGE =
  'usage: /notepad [add <text> | done <id…> | rm <id…> | show]'

const ids = (rest: string): number[] =>
  rest
    .split(/[\s,]+/)
    .map(s => Number(s.replace(/^#/, '')))
    .filter(n => Number.isInteger(n) && n > 0)

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'notepad',
      description: 'Session notepad: open the pane, or add/done/rm items',
    })
    await $.tool.register({
      name: TOOL,
      description: INSTRUCTIONS,
      isDeferred: false,
      inputSchema: {
        type: 'object',
        properties: {
          add: { type: 'array', items: { type: 'string' }, description: 'New items, one short line each' },
          done: { type: 'array', items: { type: 'integer' }, description: 'Ids done or no longer relevant, removed from the list' },
          remove: { type: 'array', items: { type: 'integer' }, description: 'Ids to delete' },
          edit: {
            type: 'array',
            items: {
              type: 'object',
              properties: { id: { type: 'integer' }, text: { type: 'string' } },
              required: ['id', 'text'],
            },
          },
        },
      },
    })
    await sync($)
    void $.ui.open({ id: PANE, title: 'Notepad' })

    return next(e)
  })

  on('turn.start', async ($, e, next) => {
    await sync($)

    return next(e)
  })

  on('tool.call', { tool: TOOL_FULL }, async ($, e) => {
    const pad = await change($, e as unknown as Ops)

    return { result: format(pad) }
  })

  on('command.run', { command: 'notepad' }, async ($, e) => {
    const [verb = '', ...restParts] = e.args.trim().split(/\s+/)
    const rest = restParts.join(' ')
    const ops: Ops | null =
      verb === 'add' && rest !== '' ? { add: [rest] }
      : verb === 'done' ? { done: ids(rest) }
      : verb === 'rm' ? { remove: ids(rest) }
      : null

    if (ops === null) {
      await $.ui.open({ id: PANE, title: 'Notepad' })
      const pad = await sync($)

      return { text: verb === '' || verb === 'show' ? format(pad) : USAGE }
    }

    const pad = await change($, ops)

    return { text: format(pad) }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const { items } = await read($, notepad)
    const room = Math.max(1, (e.viewport?.rows ?? 24) - 3)
    const shown = items.slice(0, room)

    return (
      <Box flexDirection="column">
        {items.length === 0 && <Text dimColor>Nothing pending yet.</Text>}
        {shown.map(i => (
          <Text>
            • {i.text} <Text dimColor>#{i.id}</Text>
          </Text>
        ))}
        {items.length > shown.length && (
          <Text dimColor>+{items.length - shown.length} more, /notepad show</Text>
        )}
      </Box>
    )
  })
}
