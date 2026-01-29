import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:evostream/utils/integer_extension.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class SoundService {
  static final SoundService _instance = SoundService._();

  final Completer<void> _initCompleter = Completer<void>();
  final Set<AudioSource> _activeSources = {};

  SoLoud? _soloud;
  final int _sampleRate = 44100;

  SoundService._() {
    _init();
  }

  factory SoundService() => _instance;

  Future<void> _init() async {
    try {
      _soloud = SoLoud.instance;
      await _soloud!.init();
      _initCompleter.complete();
    } catch (e) {
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }

  Future<void> dispose() async {
    await _initCompleter.future;
    if (_soloud == null) return;

    final sourcesToDispose = List<AudioSource>.from(_activeSources);
    for (final source in sourcesToDispose) {
      await _soloud!.disposeSource(source);
    }
    _activeSources.clear();

    _soloud!.deinit();
    _soloud = null;
  }

  Future<void> _playTone({
    required double frequency,
    required int durationMs,
    double volume = 1.0,
  }) async {
    await _initCompleter.future;

    if (_soloud == null || !_soloud!.isInitialized) return;

    final len = (_sampleRate * durationMs / 1000).round();
    final Float32List floatBuffer = Float32List(len);

    for (int i = 0; i < len; i++) {
      floatBuffer[i] = sin(2 * pi * frequency * i / _sampleRate) * volume;
    }

    // Create the source
    final AudioSource streamSource = _soloud!.setBufferStream(
      maxBufferSizeBytes: len * Float32List.bytesPerElement,
      bufferingType: BufferingType.released,
      bufferingTimeNeeds: durationMs / 1000.0,
      sampleRate: _sampleRate,
      channels: Channels.mono,
      format: BufferType.f32le,
    );

    _activeSources.add(streamSource);

    _soloud!.addAudioDataStream(
      streamSource,
      Uint8List.view(floatBuffer.buffer),
    );

    await _soloud!.play(streamSource);

    // Wait for the duration
    await Future.delayed(Duration(milliseconds: durationMs + 50));

    // Cleanup
    if (_soloud != null && _activeSources.contains(streamSource)) {
      await _soloud!.disposeSource(streamSource);
      _activeSources.remove(streamSource);
    }
  }

  Future countDown([int from = 3]) async {
    for (var i = 0; i < from; i++) {
      await _playTone(frequency: 1000, durationMs: 200);
      await Future.delayed(800.ms);
    }
  }

  Future beep() async {
    await _playTone(frequency: 1000, durationMs: 200);
  }

  Future startBeep() async {
    await _playTone(frequency: 1000, durationMs: 200);
    await _playTone(frequency: 1500, durationMs: 800);
  }

  Future endBeep() async {
    await _playTone(frequency: 1000, durationMs: 200);
    await _playTone(frequency: 500, durationMs: 800);
  }

  Future finishBeep() async {
    await _playTone(frequency: 1000, durationMs: 200);
    await _playTone(frequency: 500, durationMs: 600);
    await Future.delayed(200.ms);
    await _playTone(frequency: 500, durationMs: 600);
    await Future.delayed(200.ms);
    await _playTone(frequency: 500, durationMs: 600);
  }
}
