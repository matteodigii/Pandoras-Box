/*
  ==============================================================================

	This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"
#include "ParamIDs.h"

//==============================================================================
PandoraFxAudioProcessorEditor::PandoraFxAudioProcessorEditor(PandoraFxAudioProcessor& p)
	: AudioProcessorEditor(&p), audioProcessor(p)
{
	// Make sure that before the constructor has finished, you've set the
	// editor's size to whatever you need it to be.
	setSize(600, 600);

	// 1 - Distortion: Mix and Drive
	distSlider.setSliderStyle(juce::Slider::SliderStyle::LinearHorizontal);
	distSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	distSlider.setRange(Parameters::distortion::mixMinValue, Parameters::distortion::mixMaxValue, 0.01);
	distLabel.setText(Parameters::distortion::mixLabel, juce::dontSendNotification);

	
	distDriveSlider.setSliderStyle(juce::Slider::SliderStyle::RotaryHorizontalVerticalDrag);
	distDriveSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	distDriveSlider.setRange(Parameters::distortion::driveMinValue, Parameters::distortion::driveMaxValue, 0.01);
	distDriveLabel.setText(Parameters::distortion::driveLabel, juce::dontSendNotification);
	

	// 2 - Reverb: Mix, Room and Decay
	reverbSlider.setSliderStyle(juce::Slider::SliderStyle::LinearHorizontal);
	reverbSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	reverbSlider.setRange(Parameters::reverb::mixMinValue, Parameters::reverb::mixMaxValue, 0.01);
	reverbLabel.setText(Parameters::reverb::mixLabel, juce::dontSendNotification);

	reverbRoomSlider.setSliderStyle(juce::Slider::SliderStyle::RotaryHorizontalVerticalDrag);
	reverbRoomSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	reverbRoomSlider.setRange(Parameters::reverb::roomMinValue, Parameters::reverb::roomMaxValue, 0.01);
	reverbRoomLabel.setText(Parameters::reverb::roomLabel, juce::dontSendNotification);

	reverbWidthSlider.setSliderStyle(juce::Slider::SliderStyle::RotaryHorizontalVerticalDrag);
	reverbWidthSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	reverbWidthSlider.setRange(Parameters::reverb::widthMinValue, Parameters::reverb::widthMaxValue, 0.01);
	reverbWidthLabel.setText(Parameters::reverb::widthLabel, juce::dontSendNotification);

	// 3 - Phaser: Mix, for the moment it is not present in the GUI
	phaserSlider.setSliderStyle(juce::Slider::SliderStyle::LinearHorizontal);
	phaserSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	phaserSlider.setRange(Parameters::phaser::mixMinValue, Parameters::phaser::mixMaxValue, 0.01);
	phaserLabel.setText(Parameters::phaser::mixLabel, juce::dontSendNotification);

	// 4 - Chorus: Mix, Rate and Depth
	chorusSlider.setSliderStyle(juce::Slider::SliderStyle::LinearHorizontal);
	chorusSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	chorusSlider.setRange(Parameters::chorus::mixMinValue, Parameters::chorus::mixMaxValue, 0.01);
	chorusLabel.setText(Parameters::chorus::mixLabel, juce::dontSendNotification);

	chorusRateSlider.setSliderStyle(juce::Slider::SliderStyle::RotaryHorizontalVerticalDrag);
	chorusRateSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	chorusRateSlider.setRange(Parameters::chorus::rateMinValue, Parameters::chorus::rateMaxValue, 0.01);
	chorusRateLabel.setText(Parameters::chorus::rateLabel, juce::dontSendNotification);

	chorusDepthSlider.setSliderStyle(juce::Slider::SliderStyle::RotaryHorizontalVerticalDrag);
	chorusDepthSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	chorusDepthSlider.setRange(Parameters::chorus::depthMinValue, Parameters::chorus::depthMaxValue, 0.01);
	chorusDepthLabel.setText(Parameters::chorus::depthLabel, juce::dontSendNotification);

	// 5 - Delay: Mix, Feedback and Time
	delaySlider.setSliderStyle(juce::Slider::SliderStyle::LinearHorizontal);
	delaySlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	delaySlider.setRange(Parameters::delay::mixMinValue, Parameters::delay::mixMaxValue, 0.01);
	delayLabel.setText(Parameters::delay::mixLabel, juce::dontSendNotification);

	delayFbSlider.setSliderStyle(juce::Slider::SliderStyle::RotaryHorizontalVerticalDrag);
	delayFbSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	delayFbSlider.setRange(Parameters::delay::fbMinValue, Parameters::delay::fbMaxValue, 0.01);
	delayFbLabel.setText(Parameters::delay::fbLabel, juce::dontSendNotification);

	delayTimeSlider.setSliderStyle(juce::Slider::SliderStyle::RotaryHorizontalVerticalDrag);
	delayTimeSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 40, 20);
	delayTimeSlider.setRange(Parameters::delay::timeMinValue, Parameters::delay::timeMaxValue, 0.01);
	delayTimeLabel.setText(Parameters::delay::timeLabel, juce::dontSendNotification);

	// 6 - Post Gain
	gainSlider.setSliderStyle(juce::Slider::SliderStyle::LinearHorizontal);
	gainSlider.setTextBoxStyle(juce::Slider::TextEntryBoxPosition::TextBoxRight, true, 50, 20);
	gainSlider.setRange(Parameters::gain::minValue, Parameters::gain::maxValue, 0.01);
	gainLabel.setText(Parameters::gain::label, juce::dontSendNotification);


	// Distortion
	addAndMakeVisible(distSlider);
	addAndMakeVisible(distLabel);
	addAndMakeVisible(distDriveSlider);
	addAndMakeVisible(distDriveLabel);

	// Reverb
	addAndMakeVisible(reverbSlider);
	addAndMakeVisible(reverbLabel);
	addAndMakeVisible(reverbRoomSlider);
	addAndMakeVisible(reverbRoomLabel);
	addAndMakeVisible(reverbWidthSlider);
	addAndMakeVisible(reverbWidthLabel);

	// Phaser, obscured since we've removed the case from the switch
	addAndMakeVisible(phaserSlider);
	addAndMakeVisible(phaserLabel);

	// Chorus
	addAndMakeVisible(chorusSlider);
	addAndMakeVisible(chorusLabel);
	addAndMakeVisible(chorusRateSlider);
	addAndMakeVisible(chorusRateLabel);
	addAndMakeVisible(chorusDepthSlider);
	addAndMakeVisible(chorusDepthLabel);

	// Delay
	addAndMakeVisible(delaySlider);
	addAndMakeVisible(delayLabel);
	addAndMakeVisible(delayFbSlider);
	addAndMakeVisible(delayFbLabel);
	addAndMakeVisible(delayTimeSlider);
	addAndMakeVisible(delayTimeLabel);

	// Gain
	addAndMakeVisible(gainSlider);
	addAndMakeVisible(gainLabel);

	// Attachments:
	// 
	// 1 - Distortion
	distAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::distortion::mixId, distSlider);
	distDriveAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::distortion::driveId, distDriveSlider);

	// 2 - Reverb
	reverbAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::reverb::mixId, reverbSlider);
	reverbRoomAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::reverb::roomId, reverbRoomSlider);
	reverbWidthAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::reverb::widthId, reverbWidthSlider);

	// 3 - Phaser
	phaserAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::phaser::mixId, phaserSlider);

	// 4 - Chorus
	chorusAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::chorus::mixId, chorusSlider);
	chorusRateAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::chorus::rateId, chorusRateSlider);
	chorusDepthAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::chorus::depthId, chorusDepthSlider);
	
	// 5 - Delay 
	delayAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::delay::mixId, delaySlider);
	delayFbAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::delay::fbId, delayFbSlider);
	delayTimeAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::delay::timeId, delayTimeSlider);
	
	// 6 - Post Gain
	gainAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(audioProcessor.apvts, Parameters::gain::id, gainSlider);
}

PandoraFxAudioProcessorEditor::~PandoraFxAudioProcessorEditor()
{
}

//==============================================================================
void PandoraFxAudioProcessorEditor::paint(juce::Graphics& g)
{
	// (Our component is opaque, so we must completely fill the background with a solid colour)
	g.fillAll(getLookAndFeel().findColour(juce::ResizableWindow::backgroundColourId));

	g.setColour(juce::Colours::white);
	g.setFont(juce::FontOptions(15.0f));
}

void PandoraFxAudioProcessorEditor::resized()
{
	auto area = getLocalBounds().reduced(10);

	// Reserve space for gain slider at the bottom
	auto gainHeight = 40;
	auto gainArea = area.removeFromBottom(gainHeight);

	// Divide the remaining area into top and bottom halves
	auto topHalf = area.removeFromTop(area.getHeight() / 2);
	auto bottomHalf = area;

	// Now divide top and bottom halves into left and right
	auto topLeft = topHalf.removeFromLeft(topHalf.getWidth() / 2);
	auto topRight = topHalf;
	auto bottomLeft = bottomHalf.removeFromLeft(bottomHalf.getWidth() / 2);
	auto bottomRight = bottomHalf;

	// ====================
	// Top-Left: Distortion
	// ====================
	auto distHeader = topLeft.removeFromTop(20);
	distLabel.setBounds(distHeader);

	auto distMixArea = topLeft.removeFromTop(40);
	distSlider.setBounds(distMixArea);

	auto distKnobArea = topLeft;
	auto driveArea = distKnobArea.removeFromLeft(distKnobArea.getWidth() / 2);
	distDriveLabel.setBounds(driveArea.removeFromTop(20));
	distDriveSlider.setBounds(driveArea);

	// ====================
	// Top-Right: Chorus
	// ====================
	// Label
	auto chorusHeader = topRight.removeFromTop(20);
	chorusLabel.setBounds(chorusHeader);

	// Mix slider
	auto chorusMixArea = topRight.removeFromTop(40);
	chorusSlider.setBounds(chorusMixArea);

	// Knobs: rate e depth affiancate
	auto chorusKnobArea = topRight;
	auto rateArea = chorusKnobArea.removeFromLeft(chorusKnobArea.getWidth() / 2);
	auto depthArea = chorusKnobArea;

	chorusRateLabel.setBounds(rateArea.removeFromTop(20));
	chorusRateSlider.setBounds(rateArea);

	chorusDepthLabel.setBounds(depthArea.removeFromTop(20));
	chorusDepthSlider.setBounds(depthArea);


	// ========================
	// Bottom-Right: Delay section
	// ========================
	auto delayHeader = bottomRight.removeFromTop(20);
	delayLabel.setBounds(delayHeader);

	auto delayMixArea = bottomRight.removeFromTop(40);
	delaySlider.setBounds(delayMixArea);

	// Place fb and time knobs side-by-side below the mix slider
	auto delayKnobArea = bottomRight;
	auto fbArea = delayKnobArea.removeFromLeft(delayKnobArea.getWidth() / 2);
	auto timeArea = delayKnobArea;

	delayFbLabel.setBounds(fbArea.removeFromTop(20));
	delayFbSlider.setBounds(fbArea);

	delayTimeLabel.setBounds(timeArea.removeFromTop(20));
	delayTimeSlider.setBounds(timeArea);


	// ====================
	// Bottom-Left: Reverb
	// ====================
	// Label
	auto reverbHeader = bottomLeft.removeFromTop(20);
	reverbLabel.setBounds(reverbHeader);

	// Mix slider
	auto reverbMixArea = bottomLeft.removeFromTop(40);
	reverbSlider.setBounds(reverbMixArea);

	// Knobs: room e decay affiancate
	auto reverbKnobArea = bottomLeft;
	auto roomArea = reverbKnobArea.removeFromLeft(reverbKnobArea.getWidth() / 2);
	auto decayArea = reverbKnobArea;

	reverbRoomLabel.setBounds(roomArea.removeFromTop(20));
	reverbRoomSlider.setBounds(roomArea);

	reverbWidthLabel.setBounds(decayArea.removeFromTop(20));
	reverbWidthSlider.setBounds(decayArea);


	// ====================
	// Gain slider
	// ====================
	gainLabel.setBounds(gainArea.removeFromTop(20));
	gainSlider.setBounds(gainArea);
}
