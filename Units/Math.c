Count_Sound_Coeff:
fild [ds:SampleValue]
fmul [ds:SamplingSize]
fdiv [ds:SoundCoeff]
fstp [ds:MainCoeff]
ret