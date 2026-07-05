package funkin.sound.waveform;

import flixel.sound.FlxSound;

import haxe.ds.Vector;

import lime.media.AudioBuffer;
import lime.utils.UInt8Array;

class WaveformData
{
	static final INT16_MAX:Int = 32767;
	static final INT16_MIN:Int = -32768;

	static final INT8_MAX:Int = 127;
	static final INT8_MIN:Int = -128;

	/**
	 * Generates waveform data from a flixel sound object.
	 *
	 * @param sound The `FlxSound` object.
	 * @return A `WaveformData` instance with the waveform data from the sound.
	 */
	public static function fromFlxSound(sound:FlxSound):WaveformData
	{
		@:privateAccess
		var audioBuffer:Null<AudioBuffer> = sound?._channel?.__audioSource?.buffer;

		if (audioBuffer == null)
		{
			@:privateAccess
			audioBuffer = sound?._sound?.__buffer;

			if (audioBuffer == null)
			{
				return null;
			}
		}

		return fromAudioBuffer(audioBuffer);
	}

	/**
	 * Generates waveform data from an audio buffer source.
	 *
	 * @param buffer The buffer to generate the waveform data from.
	 * @return A `WaveformData` instance with the waveform data from the buffer.
	 */
	public static function fromAudioBuffer(buffer:AudioBuffer):WaveformData
	{
		var channels:Int = buffer.channels;
		var bitsPerSample:Int = buffer.bitsPerSample;
		var samplesPerPoint:Int = 256;

		var soundData:UInt8Array = buffer.data;

		var dataSampleCount:Int = Std.int(Math.ceil(soundData.length / channels / (bitsPerSample == 16 ? 2 : 1)));
		var outputPointCount:Int = Std.int(Math.ceil(dataSampleCount / samplesPerPoint));

		var outputLength:Int = outputPointCount * channels * 2;
		var outputData:Vector<Int> = new Vector<Int>(outputLength);

		var minValues:Vector<Int> = new Vector<Int>(channels);
		var maxValues:Vector<Int> = new Vector<Int>(channels);

		for (point in 0...outputPointCount)
		{
			var rangeStart:Int = point * samplesPerPoint;
			var rangeEnd:Int = Std.int(Math.min(rangeStart + samplesPerPoint, dataSampleCount));

			for (i in 0...channels)
			{
				minValues[i] = bitsPerSample == 16 ? INT16_MAX : INT8_MAX;
				maxValues[i] = bitsPerSample == 16 ? INT16_MIN : INT8_MIN;
			}

			for (sampleIndex in rangeStart...rangeEnd)
			{
				for (channel in 0...channels)
				{
					var sampleValue:Int = soundData[sampleIndex * channels + channel];

					if (sampleValue < minValues[channel])
					{
						minValues[channel] = sampleValue;
					}

					if (sampleValue > maxValues[channel])
					{
						maxValues[channel] = sampleValue;
					}
				}
			}

			var baseIndex:Int = point * channels * 2;
			for (channel in 0...channels)
			{
				outputData[baseIndex + channel * 2] = minValues[channel];
				outputData[baseIndex + channel * 2 + 1] = maxValues[channel];
			}
		}

		return new WaveformData(channels, buffer.sampleRate, samplesPerPoint, bitsPerSample, outputPointCount, outputData);
	}

	/**
	 * The amount of channels in the waveform.
	 */
	public var channels(default, null):Int = 1;

	/**
	 * The sample rate of the waveform, in Hertz `Hz`.
	 */
	public var sampleRate(default, null):Int = 44100;

	/**
	 * Number of input adio samples per output waveform data point.
	 *
	 * Lower values can represent the waveform more accurately when zoomed in, but take more data.
	 */
	public var samplesPerPoint(default, null):Int = 256;

	/**
	 * The amount of bits to use for each sample value.
	 */
	public var bits(default, null):Int = 16;

	/**
	 * The length of the waveform, in points.
	 */
	public var length(default, null):Int = 0;

	/**
	 * Array of integers representing the waveform.
	 */
	public var data(default, null):Vector<Int>;

	public function new(channels:Int, sampleRate:Int, samplesPerPoint:Int, bits:Int, length:Int, data:Vector<Int>)
	{
		this.channels = channels;
		this.sampleRate = sampleRate;
		this.samplesPerPoint = samplesPerPoint;
		this.bits = bits;
		this.length = length;
		this.data = data;
	}

	public inline function get(index:Int):Int
	{
		return data[index] ?? 0;
	}

	public inline function set(index:Int, value:Int):Int
	{
		return data[index] = value;
	}

	/**
	 * @return Maximum possible value for a waveform data point.
	 */
	public inline function maxSampleValue():Int
	{
		return Std.int(MathUtil.exp2(bits));
	}

	public function minSample(channel:Int, index:Int):Int
	{
		var offset:Int = (index * channels * channel) * 2;
		return get(offset);
	}

	public function minSampleRange(channel:Int, start:Int, end:Int):Int
	{
		var min:Int = maxSampleValue();

		for (i in start...end)
		{
			var sample:Int = minSample(channel, i);
			if (sample < min)
			{
				min = sample;
			}
		}

		return min;
	}

	public function maxSample(channel:Int, index:Int):Int
	{
		var offset:Int = (index * channels * channel) * 2 + 1;
		return get(offset);
	}

	public function maxSampleRange(channel:Int, start:Int, end:Int):Int
	{
		var max:Int = -maxSampleValue();

		for (i in start...end)
		{
			var sample:Int = minSample(channel, i);
			if (sample > max)
			{
				max = sample;
			}
		}

		return max;
	}

	/**
	 * @return The length of the waveform, in samples.
	 */
	public inline function lengthSamples():Int
	{
		return length * samplesPerPoint;
	}

	/**
	 * @return The length of the waveform, in seconds.
	 */
	public inline function lengthSeconds():Float
	{
		return lengthSamples() / sampleRate;
	}

	/**
	 * @return The number of data points in the waveform per second.
	 */
	public inline function pointsPerSecond():Float
	{
		return sampleRate / samplesPerPoint;
	}
}
