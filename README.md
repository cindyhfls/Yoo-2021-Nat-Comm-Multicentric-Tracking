# Readme

This is the neuron tuning modeling part of the paper "[Multicentric tracking of multiple agents by anterior cingulate cortex during pursuit and evasion](https://www.nature.com/articles/s41467-021-22195-z)" by Seng Bum Michael Yoo, Jiaxin Cindy Tu and Benjamin Yost Hayden, Nature Communications (2021). This same model was also used in [The neural basis of predictive pursuit](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7007341/) and my sfn poster (2018) presentation "Neural representation of allocentric and egocentric positions in a dynamic foraging task".

The example data is excluded in ./Data, along with the code to generate it from raw spike trains and behavior in ./FormatData.

We got the inspiration from the coding properties of neurons in the mice medial entorhinal cortex and built our models using the pipeline proposed in this paper: "[A Multiplexed, Heterogeneous, and Adaptive Code for Navigation in Medial Entorhinal Cortex](https://www.sciencedirect.com/science/article/pii/S0896627317302374)".

The details are summarized below and described in depth in the paper. The LN models estimated the spike rate (ri) of one neuron during time bin t as an exponential function of the sum of the relevant value of each variable at time t projected onto a corresponding set of parameters (wi). The Poisson log-likelihood of the observed spike train given the behavioral variables using the MATLAB function "fminunc". Model performance of each neuron is quantified by the log-likelihood of held-out data under the model.This cross-validation procedure was repeated ten times and overfitting was penalized. Forward variable selection was conducted to find the range of variables that best predicts the single-neuron's firing rate using cross-validation log-likelihood. 

