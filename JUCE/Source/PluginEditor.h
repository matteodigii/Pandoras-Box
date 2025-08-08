#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

//==============================================================================
/**
*/
class PandoraFxAudioProcessorEditor : public juce::AudioProcessorEditor
{
public:
	PandoraFxAudioProcessorEditor(PandoraFxAudioProcessor&);
	~PandoraFxAudioProcessorEditor() override;

	//==============================================================================
	void paint(juce::Graphics&) override;
	void resized() override;

private:
	// This reference is provided as a quick way for your editor to
	// access the processor object that created it.
	PandoraFxAudioProcessor& audioProcessor;

	// Distortion
	juce::Slider distSlider;
	juce::Label distLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> distAttachment;

	juce::Slider distDriveSlider;
	juce::Label distDriveLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> distDriveAttachment;

	// Reverb
	juce::Slider reverbSlider;
	juce::Label reverbLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> reverbAttachment;

	juce::Slider reverbRoomSlider;
	juce::Label reverbRoomLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> reverbRoomAttachment;

	juce::Slider reverbWidthSlider;
	juce::Label reverbWidthLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> reverbWidthAttachment;

	// Phaser
	juce::Slider phaserSlider;
	juce::Label phaserLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> phaserAttachment;

	// Chorus
	juce::Slider chorusSlider;
	juce::Label chorusLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> chorusAttachment;

	juce::Slider chorusRateSlider;
	juce::Label chorusRateLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> chorusRateAttachment;

	juce::Slider chorusDepthSlider;
	juce::Label chorusDepthLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> chorusDepthAttachment;

	// Delay
	juce::Slider delaySlider;
	juce::Label delayLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> delayAttachment;

	juce::Slider delayFbSlider;
	juce::Label delayFbLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> delayFbAttachment;

	juce::Slider delayTimeSlider;
	juce::Label delayTimeLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> delayTimeAttachment;

	// Gain
	juce::Slider gainSlider;
	juce::Label gainLabel;
	std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> gainAttachment;

	JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PandoraFxAudioProcessorEditor)
};
