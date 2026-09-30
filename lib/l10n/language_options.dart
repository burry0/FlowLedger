/// Supported languages, each named in its own language.
class LanguageOption {
  const LanguageOption(this.code, this.nativeName);

  final String code;
  final String nativeName;
}

const languageOptions = <LanguageOption>[
  LanguageOption('tr', 'Türkçe'),
  LanguageOption('en', 'English'),
  LanguageOption('de', 'Deutsch'),
  LanguageOption('ru', 'Русский'),
];
