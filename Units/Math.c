Count_Sound_Coeff:
fild [SampleValue]
fmul [SamplingSize]
fdiv [SoundCoeff]
fstp [MainCoeff]
ret