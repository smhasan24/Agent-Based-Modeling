# Disease Spread Agent-Based Model

This repository contains an agent-based model (ABM) for simulating the spread of disease within a population. The model is designed to optimize policy decisions and provide insights for healthcare policy and research, focusing on factors such as population density, social distancing, and self-isolation.

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [How It Works](#how-it-works)
- [How to Use](#how-to-use)
- [Things to Notice](#things-to-notice)
- [Things to Try](#things-to-try)
- [Extending the Model](#extending-the-model)
- [NetLogo Features](#netlogo-features)
- [Credits and References](#credits-and-references)

## Introduction
This NetLogo model simulates the spread of a disease within a population divided into two regions: pink and gray. The model allows users to explore the effects of various interventions such as travel restrictions, social distancing, and self-isolation on the spread of the disease.

## Features
- **Population Division**: The population is divided into two regions (pink and gray) with different initial conditions.
- **Interventions**: Users can toggle travel restrictions, social distancing, and self-isolation to see their effects.
- **Real-Time Monitoring**: The model provides real-time updates on infection rates, death counts, and immunity levels.
- **Customizable Parameters**: Users can adjust parameters such as population size, infection rate, survival rate, and more.

## How It Works
The model uses turtles to represent individuals in the population. Each turtle has attributes such as infection status, antibodies, and group affiliation. The model simulates the spread of the disease based on interactions between turtles and the effects of various interventions.

![ABM model Features](https://github.com/smhasan24/Agent-Based-Modeling/blob/main/ABM.png)

### Rules for Agents
- **Movement**: Turtles move randomly, with adjustments for social distancing and travel restrictions.
- **Infection Spread**: Infected turtles can spread the disease to nearby susceptible turtles based on the infection rate.
- **Recovery and Death**: Infected turtles have a chance to recover and gain immunity or die based on the survival rate.
- **Interventions**: Travel restrictions, social distancing, and self-isolation can be toggled to see their impact on disease spread.

## How to Use
1. **Setup the World**: Click the `setup_world` button to initialize the simulation environment.
2. **Setup Agents**: Click the `setup_agents` button to create the population and set initial conditions.
3. **Run the Model**: Click the `run_model` button to start the simulation. The model will run step-by-step, and you can observe the changes in real-time.

### Interface Controls
- **Sliders**: Adjust parameters such as population size, infection rate, survival rate, etc.
- **Switches**: Toggle interventions like travel restrictions, social distancing, and self-isolation.
- **Monitors**: View real-time statistics such as infection percentages, death counts, and immunity levels.
- **Plots**: Visualize the population dynamics over time.

## Things to Notice
- **Infection Rates**: Observe how infection rates differ between the pink and gray regions.
- **Intervention Effects**: Notice how interventions like social distancing and self-isolation impact the spread of the disease.
- **Immunity Levels**: Track the development of immunity within the population over time.

## Things to Try
- **Adjust Parameters**: Experiment with different parameter settings to see how they affect the outcome of the simulation.
- **Compare Interventions**: Compare the effectiveness of different interventions by toggling them on and off.
- **Population Density**: Modify the population density to see its impact on disease spread.

## Extending the Model
- **Additional Interventions**: Add new interventions such as vaccination campaigns or quarantine measures.
- **Multiple Regions**: Extend the model to include more regions with different characteristics.
- **Data Export**: Implement functionality to export simulation data for further analysis.

## NetLogo Features
- **Turtles and Patches**: The model uses turtles to represent individuals and patches to represent regions.
- **Real-Time Monitoring**: The model uses monitors and plots to provide real-time feedback on the simulation.
- **Customizable Interface**: The interface includes sliders, switches, and buttons for easy interaction with the model.

## Credits and References
- **NetLogo**: The model is built using NetLogo, a multi-agent programmable modeling environment.
- **Author**: S M Mahamudul Hasan
- **Student ID**: 23106367

For more information about the author, visit the [LinkedIN](https://www.linkedin.com/in/hasanmahmud032/).

---

Feel free to explore, modify, and extend this model to suit your needs. If you have any questions or suggestions, please open an issue or submit a pull request. Happy modeling!
