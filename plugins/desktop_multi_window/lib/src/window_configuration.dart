class WindowConfiguration {
  const WindowConfiguration({
    required this.arguments,
    this.hiddenAtLaunch = true,
    this.isPanel = false,
  });

  /// The arguments passed to the new window.
  final String arguments;
  final bool hiddenAtLaunch;
  final bool isPanel;

  factory WindowConfiguration.fromJson(Map<String, dynamic> json) {
    return WindowConfiguration(
      arguments: json['arguments'] as String? ?? '',
      hiddenAtLaunch: json['hiddenAtLaunch'] as bool? ?? false,
      isPanel: json['isPanel'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arguments': arguments,
      'hiddenAtLaunch': hiddenAtLaunch,
      'isPanel': isPanel,
    };
  }

  @override
  String toString() {
    return 'WindowConfiguration(arguments: $arguments, hiddenAtLaunch: $hiddenAtLaunch, isPanel: $isPanel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WindowConfiguration &&
        other.arguments == arguments &&
        other.hiddenAtLaunch == hiddenAtLaunch && 
        other.isPanel == isPanel;
  }

  @override
  int get hashCode {
    return arguments.hashCode ^ hiddenAtLaunch.hashCode ^ isPanel.hashCode;
  }
}
