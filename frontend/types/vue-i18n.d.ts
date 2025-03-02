import 'vue-i18n'

declare module 'vue-i18n' {
  // define the locale messages schema
  export interface DefineLocaleMessage {
    [key: string]: string | DefineLocaleMessage
  }
}

declare module '@vue/runtime-core' {
  export interface ComponentCustomProperties {
    $t: (key: string, values?: Record<string, any>) => string
    $i18n: {
      locale: string
      t: (key: string, values?: Record<string, any>) => string
    }
  }
}
