s.plotTree;
s.freeAll;

s.boot;

/* --- VST --- */
// Define VST Node
(
SynthDef(\effects, { |in, out|
	var sound = In.ar(in, 2);
	ReplaceOut.ar(out, VSTPlugin.ar(sound, 2, id: \effects));
}).add;
)

// Create bus where the FX will be applied
~effectsBus = Bus.audio(s, 2);

// Create VST node instance
~effectsFx = Synth(\effects, [\in, ~effectsBus, \out, 0]);

// Create VST controller object
~effectsController = VSTPluginController(~effectsFx, id: \effects);

// Open the VST
// To find the path, run VSTPlugin.search and copy the path of the preferred VST
VSTPlugin.search(s, "C:/Users/thesk/Desktop/Builds");
~effectsController.open("C:/Users/thesk/Desktop/Builds/VisualStudio2022/x64/Debug/VST3/PandoraFx.vst3", editor: true, verbose: true);

// Open the VST interface
~effectsController.editor;

// Mapping VST
// 0 dist mix, 1 dist drive
// 2 rev mix, 3 rev room,
// 4 rev width, 7 chorus mix
// 8 chorus rate, 9 chorus depth
// 10 delay mix, 11 delay feedback
// 12 delay time, 13 gain

/* --- OSC --- */
NetAddr("127.0.0.1", 57120);
(
OSCdef("OSCreceiver", {
	arg msg;

	var tl = msg[1];
	var tr = msg[2];
	var br = msg[3];
	var bl = msg[4];

	//postln("tl: " + tl + ", tr: " + tr);
	//postln("br: " + br + ", bl: " + bl);

	// set parameters according to received values
~effectsController.set(0, tl);	~effectsController.set(2, br);	~effectsController.set(7, tr);	~effectsController.set(10, bl);

}, "/coordinates");

OSCdef("OSCreceiver", {
	arg msg;

	var dist_drive = msg[1];
	var chorus_rate = msg[2];
	var chorus_depth = msg[3];
	var rev_room = msg[4];
	var rev_width = msg[5];
	var del_fb = msg[6];
	var del_time = msg[7];


	// set parameters according to received values
	~effectsController.set(1, dist_drive);
	~effectsController.set(3, rev_room);
	~effectsController.set(4, rev_width);
	~effectsController.set(8, chorus_rate);
	~effectsController.set(9, chorus_depth);
	~effectsController.set(11, del_fb);
	~effectsController.set(12, del_time);
	// ...

}, "/parameters");

)

~controlBusCounter = 0;

/* --- S Y N T H E S I S --- */
(
MIDIClient.init;
MIDIIn.connectAll;

~note = nil;

if (~controlBusCounter == 0) {
	~modBusses = Array.fill(4, {Bus.control(s, 1)}).postln;
	~controlBusCounter = ~controlBusCounter + 1;
};
  //Alloco i bus per i fare il routing dei modulatori
~fluteSynth = Array.newClear(128);
~modSynths = Array.fill(4, { nil });
~vibRate; ~vibDepth; ~carAttack; ~carSustain; ~carRelease; ~carWaveform;

~modBus0 = -1; ~modBus1 = -1; ~modBus2 = -1; ~modBus3 = -1;

~mod0Freq = 220; ~mod0Idx = 0.2; ~mod0Waveform = 0; ~mod0Attack = 0.1; ~mod0Sustain = 0.8; ~mod0Release = 0.5; ~mod0Target = -1;

~mod1Freq = 220; ~mod1Idx = 0.2; ~mod1Waveform = 0; ~mod1Attack = 0.01; ~mod1Sustain = 0.8; ~mod1Release = 0.5; ~mod1Target = -1;

~mod2Freq = 220; ~mod2Idx = 0.2; ~mod2Waveform = 0; ~mod2Attack = 0.01; ~mod2Sustain = 0.8; ~mod2Release = 0.5; ~mod2Target = -1;

~mod3Freq = 220; ~mod3Idx = 0.2; ~mod3Waveform = 0; ~mod3Attack = 0.01; ~mod3Sustain = 0.8; ~mod3Release = 0.5; ~mod3Target = -1;

)


//---------------------------------------------CARRIER-----------------------------------------------------------------------
(
SynthDef(\pitchedFlute, {|
    freq     = 440,
	amp = 0.3,
    vibRate  = 5,
    vibDepth = 5,
    cutoff1  = 1000,
    cutoff2  = 3000,
    attack   = 0.5,
    sustain  = 1.5,
    release  = 1.5,
    gate     = 0,
    modBus0  = -1,
    modBus1  = -1,
    modBus2  = -1,
    modBus3  = -1,
	waveformType = 2
|
	var breath, vibrato;
    var upstreamMods, totalMod, pitch, sig, env;

	// Breath noise
	breath = PinkNoise.ar(amp);

	// Resonant filter for the breath
	breath = LPF.ar(breath, cutoff1);

	//Vibrato
	vibrato = SinOsc.kr(vibRate, 0, vibDepth);

	upstreamMods = [modBus0, modBus1, modBus2, modBus3].collect{ |busIndex|
    In.kr(busIndex.max(0)) * (busIndex >= 0)};

	totalMod = upstreamMods.sum;

	pitch = Select.ar(waveformType, [{SinOsc.ar(freq + vibrato + totalMod, 0, amp)},
		{Pulse.ar(freq + vibrato + totalMod, mul:amp)},
		{LFTri.ar(freq + vibrato + totalMod, 0, amp)},
		{LFSaw.ar(freq + vibrato + totalMod, 0, amp)}]);

	pitch = LPF.ar(pitch, cutoff2);

	// Mix pitch and breath together
	sig = breath + pitch;

	//Creo l'envelope
	env = EnvGen.kr(Env.adsr(attack, 0.1, 0.8, release), gate, doneAction: 2);

	sig = sig * env;
	//Output stereo
	Out.ar(~effectsBus, (Limiter.ar(sig, 0.8, 0.1)) ! 2);
}).add;
)

(
~fluteSynth = Synth(\pitchedFlute, [
  \freq, 440, \vibRate, 5, \vibDepth, 5,
  \attack, 0.5, \sustain, 1.5, \release, 1.5,
  \waveformType, 2, \modBus0, -1, \modBus1, -1,
  \modBus2, -1, \modBus3, -1, \gate, 1
]);
)

(
OSCdef(\carrierDef, { |msg, time, addr, port|
    var param = msg[1].asString;
    var value = msg[2].asFloat;

	msg.postln;

	if (param == "vibRate") {
		~vibRate = value;
		~fluteSynth[~note].set(\vibRate, value);
	};

	if (param == "vibDepth") {
		~vibDepth = value;
		~fluteSynth[~note].set(\vibDepth, value);
	};

	if (param == "attack") {
		~carAttack = value;
		~fluteSynth[~note].set(\attack, value);
	};

	if (param == "sustain") {
		~carSustain = value;
		~fluteSynth[~note].set(\sustain, value);
	};

	if (param == "release") {
		~carRelease = value;
		~fluteSynth[~note].set(\release, value);
	};

	if (param == "waveformType") {
		~carWaveform = value;
		~fluteSynth[~note].set(\waveformType, value);
	};

}, '/carrier').permanent_(true);
)

//---------------------------------------------MODULATOR--------------------------------------------------------------------

(
SynthDef(\fmModulator, { |
	outBus = 0,  //Bus a cui indirizziamo il modulatore da cui prenderlo in input per il carrier
	inBus = -1,  //Indice del bus da cui il modulatore riceve un altro modulatore in input (-1 = nessun modulatore)
	freq = 440,
	index = 100,  //Modulation index
	waveformType = 0
	gate = 1,
    attack = 0.01,
    sustain = 0.8,
    release = 0.5
|
	var modSig, env, upstream;

	upstream = In.kr(inBus.max(0)) * (inBus >= 0);

	env = EnvGen.kr(Env.asr(attack, sustain, release), gate, doneAction: 2);

	modSig = Select.kr(
		waveformType,
		[{SinOsc.kr(freq + upstream, mul: (freq + upstream) * env * index)}, {Pulse.kr(freq + upstream, mul: (freq + upstream) * env * index)}, {LFTri.kr(freq + upstream, mul: (freq + upstream) * env * index)}, {LFSaw.kr(freq + upstream, mul: (freq + upstream) * env * index)}]
	);

	Out.kr(outBus, modSig);
}).add;
)


(
OSCdef(\modControl, { | msg, time, addr, port |
	var param = msg[1].asString;
    var value = msg[2].asFloat;

	msg.postln;

	//MOD0
	if (param == "freq0") {
		~mod0Freq = value;
		~modSynths[0].set(\freq, value);
	};

	if (param == "index0") {
		~mod0Idx = value;
		~modSynths[0].set(\index, value);
	};

	if (param == "waveformType0") {
		~mod0Waveform = value;
		~modSynths[0].set(\waveformType, value);
	};

	if (param == "attack0") {
		~mod0Attack = value;
		~modSynths[0].set(\attack, value);
	};

	if (param == "sustain0") {
		~mod0Sustain = value;
		~modSynths[0].set(\sustain, value);
	};

	if (param == "release0") {
		~mod0Release = value;
		~modSynths[0].set(\release, value);
	};

	if (param == "target0") {
		if (value == 5) {
			~modBus0 = 0;
			~fluteSynth.do{arg key; key.set(\modBus0, 0)};
		};
		if (value == 2) {
			~modSynths[1].set(\inBus, 0);
		};
		if (value == 3) {
			~modSynths[2].set(\inBus, 0);
		};
		if (value == 4) {
			~modSynths[3].set(\inBus, 0);
		};
	};

	if (param == "add0") {
		~modSynths[0] = Synth.new(\fmModulator, [\freq, ~mod0Freq, \index, ~mod0Idx, \waveformType, ~mod0Waveform, \attack, ~mod0Attack, \sustain, ~mod0Sustain, \release, ~mod0Release]);
	};

	if (param == "rem0") {
		~modSynths[0].free;
	};



	if (param == "freq1") {
		~mod1Freq = value;
		~modSynths[1].set(\freq, value);
	};

	if (param == "index1") {
		~mod1Idx = value;
		~modSynths[1].set(\index, value);
	};

	if (param == "waveformType1") {
		~mod1Waveform = value;
		~modSynths[1].set(\waveformType, value);
	};

	if (param == "attack1") {
		~mod1Attack = value;
		~modSynths[1].set(\attack, value);
	};

	if (param == "sustain1") {
		~mod1Sustain = value;
		~modSynths[1].set(\sustain, value);
	};

	if (param == "release1") {
		~mod1Release = value;
		~modSynths[1].set(\release, value);
	};

	if (param == "target1") {
		if (value == 5) {
			~modBus1 = 1;
			~fluteSynth.do{arg key; key.set(\modBus1, 1)};
		};
		if (value == 1) {
			~modSynths[0].set(\inBus, 1);
		};
		if (value == 3) {
			~modSynths[2].set(\inBus, 1);
		};
		if (value == 4) {
			~modSynths[3].set(\inBus, 1);
		};
	};

	if (param == "add1") {
		~modSynths[1] = Synth.new(\fmModulator, [\freq, ~mod1Freq, \index, ~mod1Idx, \waveformType, ~mod1Waveform, \attack, ~mod1Attack, \sustain, ~mod1Sustain, \release, ~mod1Release]);
	};

	if (param == "rem1") {
		~modSynths[1].free;
	};


	if (param == "freq2") {
		~mod2Freq = value;
		~modSynths[2].set(\freq, value);
	};

	if (param == "index2") {
		~mod2Idx = value;
		~modSynths[2].set(\index, value);
	};

	if (param == "waveformType2") {
		~mod2Waveform = value;
		~modSynths[2].set(\waveformType, value);
	};

	if (param == "attack2") {
		~mod2Attack = value;
		~modSynths[2].set(\attack, value);
	};

	if (param == "sustain2") {
		~mod2Sustain = value;
		~modSynths[2].set(\sustain, value);
	};

	if (param == "release2") {
		~mod2Release = value;
		~modSynths[2].set(\release, value);
	};

	if (param == "target2") {
		if (value == 5) {
			~modBus2 = 2;
			~fluteSynth.do{arg key; key.set(\modBus2, 2)};
		};
		if (value == 2) {
			~modSynths[1].set(\inBus, 2);
		};
		if (value == 1) {
			~modSynths[0].set(\inBus, 2);
		};
		if (value == 4) {
			~modSynths[3].set(\inBus, 2);
		};
	};

	if (param == "add2") {
		~modSynths[2] = Synth.new(\fmModulator, [\freq, ~mod2Freq, \index, ~mod2Idx, \waveformType, ~mod2Waveform, \attack, ~mod2Attack, \sustain, ~mod2Sustain, \release, ~mod2Release]);
	};

	if (param == "rem2") {
		~modSynths[2].free;
	};



	if (param == "freq3") {
		~mod3Freq = value;
		~modSynths[3].set(\freq, value);
	};

	if (param == "index3") {
		~mod3Idx = value;
		~modSynths[3].set(\index, value);
	};

	if (param == "waveformType3") {
		~mod3Waveform = value;
		~modSynths[3].set(\waveformType, value);
	};

	if (param == "attack3") {
		~mod3Attack = value;
		~modSynths[3].set(\attack, value);
	};

	if (param == "sustain3") {
		~mod3Sustain = value;
		~modSynths[3].set(\sustain, value);
	};

	if (param == "release3") {
		~mod3Release = value;
		~modSynths[3].set(\release, value);
	};

	if (param == "target3") {
		if (value == 5) {
			~modBus3 = 3;
			~fluteSynth.do{arg key; key.set(\modBus3, 3)};
		};
		if (value == 2) {
			~modSynths[1].set(\inBus, 3);
		};
		if (value == 1) {
			~modSynths[0].set(\inBus, 3);
		};
		if (value == 3) {
			~modSynths[2].set(\inBus, 3);
		};
	};

	if (param == "add3") {
		~modSynths[3] = Synth.new(\fmModulator, [\freq, ~mod3Freq, \index, ~mod3Idx, \waveformType, ~mod3Waveform, \attack, ~mod3Attack, \sustain, ~mod3Sustain, \release, ~mod3Release]);
	};

	if (param == "rem3") {
		~modSynths[3].free;
	};
}, '/mod').permanent_(true);
)


//-------MIDI----------
(
MIDIdef.noteOn(\noteOn, {
	| vel, nn, chan, src |
	~note = nn;
	[vel, nn].postln;
	~fluteSynth[nn] = Synth.new(\pitchedFlute, [\freq, nn.midicps,\amp, vel.linexp(1, 127, 0.01, 0.3), \vibRate, ~vibRate, \vibDepth, ~vibDepth, \attack, ~carAttack, \sustain, ~carSustain, \release, ~carRelease, \waveformType, ~carWaveform, \modBus0, ~modBus0, \modBus1, ~modBus1, \modBus2, ~modBus2,\modBus3, ~modBus3, \gate, 1]);
}).permanent_(true);

)

(
MIDIdef.noteOff(\noteOff, {
	| vel, nn, chan, src |
	[vel, nn].postln;
	~fluteSynth[nn].set(\gate, 0);
	~fluteSynth[nn] = nil;

}).permanent_(true);
)

/*
(
OSCdef(\modControl, { |msg, time, addr, port|
    // 1) Declare everything up front
    var idx, cmdSym, val, dict, busArg;

    // 2) Unpack message
    idx    = msg[1].asInteger;
    cmdSym = msg[2].asSymbol;  // treat commands as Symbols
    // no ternary—use if to assign val
    if(msg.size > 3, { val = msg[3].asFloat }, { val = nil });

    // 3) Debug
    msg.postln;

    // 4) Shortcut to this slot’s dict
    dict = ~modParams[idx];

    // 5) If “add”, spawn synth with stored params
    if(
        cmdSym == \add,
        {
            ~modSynths[idx] = Synth(\fmModulator, [
                \outBus,       ~modBusses[idx].index,
                \inBus,        dict[\inBus],
                \freq,         dict[\freq],
                \index,        dict[\index],
                \waveformType, dict[\waveformType],
                \attack,       dict[\attack],
                \decay,        0.1,            // decay not in GUI
                \sustain,      dict[\sustain],
                \release,      dict[\release]
            ]);
            ("Modulator "++idx++" added with stored params").postln;

            // route into carrier:
            busArg = ("modBus"++idx).asSymbol;
            ~fluteSynth[~note].set(busArg, ~modBusses[idx].index);
            ("Carrier "++busArg.asString++" → bus "++~modBusses[idx].index).postln;
        },
        {
            // 6) else if “remove”, free and clear
            if(
                cmdSym == \remove,
                {
                    if(~modSynths[idx].notNil,
                        {
                            ~modSynths[idx].free;
                            ~modSynths[idx] = nil;
                            ("Modulator "++idx++" removed").postln;
                        },
                        {
                            ("⚠️ No modSynth at "++idx).postln;
                        }
                    );
                    // clear carrier routing
                    busArg = ("modBus"++idx).asSymbol;
                    ~fluteSynth[~note].set(busArg, -1);
                    ("Carrier "++busArg.asString++" cleared").postln;
                },
                {
                    // 7) else → parameter update
                    if(~modSynths[idx].notNil,
                        {
                            // store into memory
                            dict.atPut(cmdSym,
                                if(cmdSym == \inBus, { val.asInteger }, { val })
                            );
                            // update live synth
                            ~modSynths[idx].set(
                                cmdSym,
                                if(cmdSym == \inBus, { val.asInteger }, { val })
                            );
                            ("Mod"++idx++" "++cmdSym.asString++" → "++val).postln;
                        },
                        {
                            ("⚠️ ModSynth "++idx++" not ready or unknown cmd:"++cmdSym.asString).postln;
                        }
                    );
                }
            )
        }
    );
}, '/mod');
)*/