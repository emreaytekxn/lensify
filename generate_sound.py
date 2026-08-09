import wave
import struct
import math

# Audio settings
sample_rate = 44100
duration_per_note = 0.15 # seconds
amplitude = 16000

# Frequencies for "dı dı dın"
# Let's use a futuristic, pleasant chord: C5 (523.25), E5 (659.25), C6 (1046.50)
freqs = [523.25, 659.25, 1046.50]

with wave.open('assets/sounds/splash.wav', 'w') as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)

    for i, freq in enumerate(freqs):
        # Durations: first two notes short, last note longer with fade out
        duration = 0.6 if i == 2 else 0.15
        
        for t in range(int(sample_rate * duration)):
            time = t / sample_rate
            # Sine wave
            value = int(amplitude * math.sin(2.0 * math.pi * freq * time))
            
            # Simple envelope (fade in/out)
            if i == 2:
                # Fade out last note smoothly
                env = math.exp(-time * 5)
            else:
                # Small fade out for first notes to avoid clicks
                env = 1.0 - (time / duration)
                
            value = int(value * env)
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

print("Generated splash.wav")
