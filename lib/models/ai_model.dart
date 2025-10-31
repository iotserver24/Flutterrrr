class AiModel {
  final String name;
  final String description;
  final int? maxInputChars;
  final bool? reasoning;
  final List<String> inputModalities;
  final List<String> outputModalities;
  final bool? tools;
  final List<String> aliases;
  final bool? vision;
  final bool? audio;
  final bool? uncensored;
  final bool? supportsSystemMessages;
  final List<String>? voices;

  AiModel({
    required this.name,
    required this.description,
    this.maxInputChars,
    this.reasoning,
    required this.inputModalities,
    required this.outputModalities,
    this.tools,
    required this.aliases,
    this.vision,
    this.audio,
    this.uncensored,
    this.supportsSystemMessages,
    this.voices,
  });

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      name: json['name'] as String,
      description: json['description'] as String,
      maxInputChars: json['maxInputChars'] as int?,
      reasoning: json['reasoning'] as bool?,
      inputModalities: (json['input_modalities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      outputModalities: (json['output_modalities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tools: json['tools'] as bool?,
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      vision: json['vision'] as bool?,
      audio: json['audio'] as bool?,
      uncensored: json['uncensored'] as bool?,
      supportsSystemMessages: json['supportsSystemMessages'] as bool?,
      voices: (json['voices'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'maxInputChars': maxInputChars,
      'reasoning': reasoning,
      'input_modalities': inputModalities,
      'output_modalities': outputModalities,
      'tools': tools,
      'aliases': aliases,
      'vision': vision,
      'audio': audio,
      'uncensored': uncensored,
      'supportsSystemMessages': supportsSystemMessages,
      'voices': voices,
    };
  }
}
