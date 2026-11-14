export type NoteItem = { id: number; text: string; isDone: boolean }
export type Notepad = { nextId: number; items: NoteItem[]; sessionId?: string }

declare module 'claude-code' {
  interface PluginState {
    'session-notepad': { notepad: Shaped<Notepad> }
  }
}
