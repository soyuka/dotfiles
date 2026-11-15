import { expect, test } from 'claude-code/testing'
import type { TestBody } from 'claude-code/testing'

const PANE = {
  plugin: 'session-notepad',
  component: 'Pane',
  requestId: 'notepad',
  props: {
    title: 'Notepad',
    isFocused: false,
    bodyColumns: 40,
    placement: 'dock',
    scroll: { offset: 0, bodyRows: 20 },
    view: {},
  },
} as const

const boot = async (
  $: Parameters<TestBody>[0],
  on: Parameters<TestBody>[1],
  store = new Map<string, unknown>(),
) => {
  on('store.get', (_, e) => ({ value: store.get(e.key) }))
  on('store.set', (_, e) => (store.set(e.key, e.value), { value: undefined }))
  on('store.delete', (_, e) => (store.delete(e.key), { value: undefined }))
  on('store.keys', () => ({ value: [...store.keys()] }))
  on('session.id', () => ({ value: 'sid' }))
  on('command.register', () => ({ value: { command: 'notepad' } }))
  on('tool.register', () => ({ value: { tool: 'mcp__session-notepad__notepad' } }))
  on('ui.open', () => ({ value: { isPlaced: true } }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  return store
}

test('done items are removed, not struck through', async ($, on) => {
  await boot($, on)
  const added = await $.tool.call({
    tool: 'mcp__session-notepad__notepad',
    add: ['tester le démarreur', 'vérifier fusible F12', 'tester le démarreur'],
  } as never)
  expect(added.result).toBe('#1 tester le démarreur\n#2 vérifier fusible F12')

  const checked = await $.tool.call({ tool: 'mcp__session-notepad__notepad', done: [1] } as never)
  expect(checked.result).toBe('#2 vérifier fusible F12')

  const ui = await $.ui.mount({ ...PANE, surface: 'terminal' })
  expect((await ui.find({ type: 'Text', text: /fusible/ }))?.text).toContain('• vérifier fusible F12')
  expect(await ui.find({ type: 'Text', text: /démarreur/ })).toBeUndefined()
  await ui.unmount()
})

test('slash command adds and removes', async ($, on) => {
  await boot($, on)

  await $.command.run({ command: 'notepad', args: 'add check ABS' } as never)
  await $.command.run({ command: 'notepad', args: 'add check clim' } as never)
  await $.command.run({ command: 'notepad', args: 'add check phares' } as never)
  await $.command.run({ command: 'notepad', args: 'done #1' } as never)
  const out = await $.command.run({ command: 'notepad', args: 'rm 3' } as never)
  expect((out as { text: string }).text).toBe('#2 check clim')
})

test('list saved under the session id comes back on a new start', async ($, on) => {
  const store = await boot($, on, new Map<string, unknown>([
    ['pad:sid', {
      nextId: 3,
      items: [
        { id: 1, text: 'vieux point coché', isDone: true },
        { id: 2, text: 'tester le relais', isDone: false },
      ],
    }],
  ]))

  const added = await $.tool.call({ tool: 'mcp__session-notepad__notepad', add: ['vérifier fusible'] } as never)
  expect(added.result).toBe('#2 tester le relais\n#3 vérifier fusible')
  expect(store.get('pad:sid')).toEqual({
    nextId: 4,
    items: [
      { id: 2, text: 'tester le relais' },
      { id: 3, text: 'vérifier fusible' },
    ],
  })
})
