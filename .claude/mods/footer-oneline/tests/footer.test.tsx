import { expect, test } from 'claude-code/testing'
import type { TestBody } from 'claude-code/testing'

const HINT = (hint: string) =>
  ({
    plugin: 'footer-oneline',
    component: 'PromptHint',
    requestId: 'hint',
    surface: 'terminal',
    props: { isDraft: false, isWorking: false, hint },
  }) as const

const capture = ($: Parameters<TestBody>[0], on: Parameters<TestBody>[1]) => {
  const hints: string[] = []
  on('ui.render', { component: 'PromptHint' }, async (_, e, next) => {
    hints.push(e.props.hint)
    return next(e)
  })
  return hints
}

test('vim indicator is removed from the hint', async ($, on) => {
  const hints = capture($, on)
  await (await $.ui.mount(HINT('-- INSERT --'))).unmount()
  await (await $.ui.mount(HINT('-- NORMAL -- esc to interrupt'))).unmount()
  expect(hints).toEqual(['', 'esc to interrupt'])
})

test('hint without vim indicator is kept', async ($, on) => {
  const hints = capture($, on)
  await (await $.ui.mount(HINT('? for shortcuts'))).unmount()
  expect(hints).toEqual(['? for shortcuts'])
})
