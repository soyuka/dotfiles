import type { Register } from 'claude-code'

const VIM = /--\s*[A-Z][A-Z ]*\s*--/

export const register: Register = on => {
  on('ui.render', { component: 'PromptHint' }, async ($, e, next) => {
    const hint = e.props.hint.replace(VIM, ' ').replace(/\s+/g, ' ').trim()

    return next({ ...e, props: { ...e.props, hint } })
  })
}
