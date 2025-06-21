# Neural Drift
Welcome to Neural Drift, an experimental Godot app where you train a neural network to drive mini spaceships, called wings.
The app features three different tracks, and two unique modes:
- ***Genetic Mode:*** Using randomness applied through Genetic Algorithms, mutate, and apply crossover generation after generation to find the best performing wing neural network.
- ***Neural Mode:*** Uses classical feedforward neural networks and backpropagation, the wing automatically learns the player's (user) driving pattern, and tries mimicking it.

## Features
- Modern game-esque UI
- Level and Mode select menu
- Disable Post Processing for low performance devices
- Cross Platform, can run on desktop as well as mobile devices
- Parameters to tweak and experiment with training the neural networks
- Display active neural networks with their data in real time
- Save and load previously trained neural network

## The Wing's Architecture
The wings can be controlled with 3 inputs:
- Move Forward (up arrow key)
- Rotate Left (left arrow key)
- Rotate Right (right arrow key)
These will be the output of the neural network that controls the wing.
As shown below, each wing also has RayCast “sensors” ponting in 9 different directions ahead (Genetic Mode only uses 5 RayCasts). These sensors return the intersection between the wall and the RayCast.
<img src="https://github.com/user-attachments/assets/1c091330-bdbb-482c-b3c8-6229d79a0e5f" alt="Wing Sensors" width="400" />

These sensors allow the wing to know how far away the wall is, effectivelymaking it capable of “seeing” the road ahead.

These sensors will be the input of the neural network.

<img src="https://github.com/user-attachments/assets/0af48821-4e24-46ca-b4fb-c8cdb20e07f6" alt="Wing Neural Network" width="250" />

### Neural Mode Details
The project itself doesn’t use a specific dataset, as it relies on the user’s driving to create one and train the neural network (through backpropagation and gradient descent).

As the player is driving the white wing, the sensor data is being recorded, as well as the corresponding user input for that record, effectively teaching the network which control to press when it sees a certain pattern of the road ahead.

<img src="https://github.com/user-attachments/assets/65ff5bd4-bfd9-4f30-8e29-960dd332bccd" alt="Wing Training Flow" width="400" />

When training in real-time, the data is being fed to the network’s learning function in online mode, continuously. Meaning every training record is repeated immediately the assigned epoch amount.

The app also allows training the wing using existing driving data, which implements offline learning. Meaning the entire dataset is being passed through the network over each epoch.

Both online and offline learning should yield similar results.

## App UI
### Main Menu
![Main Menu](https://github.com/user-attachments/assets/c950dcc2-9007-4c63-8a81-3c9aeb7d53de)
The “Disable Post Processing” button disables all unnecessary visual effects such as glow, bloom, and lighting, to improve the app’s performance on older devices.

### Genetic Mode
![Genetic Mode](https://github.com/user-attachments/assets/958a5c2f-852d-42e5-a055-df1fc80d66c9)
- Once in a Genetic level, we can define the population size (50 by default), and generate a new random population using the “New Pop” button.
- After generating the initial random population, we can start selecting the best performing wings, an mutation them using the “mutate” button (for the last selected
wing), or “crossover” button (for the 2 last selected wings).
- We can additionally modify the mutation and crossover parameters to have control of the next generation’s inherited genes.
- Alternatively, we can press the “Auto” button to automatically select the best wing perform mutations (parameters are still manually controlled by the user).
- After selecting a wing, we can display its real-time neural network in execution by pressing the “show details” button, or by pressing the “f3” key.
- The last selected wing is always automatically saved on the filesystem, and we can load it using the “load wing” button.
- The app uses post processing effects for visuals, which can be toggled on/off using the “f2” key to improve performance.
- As an added bonus, the white wing can be controlled by the user using the arrow keys to race against the Genetic Algorithm population.

### Neural Mode
![Neural Mode](https://github.com/user-attachments/assets/9e78ddbd-b6d5-4d99-8030-37a4e7533eec)
- Once in a Neural level, we can toggle the “Train” button on, and start driving the white wing using the arrow keys.
- After driving the wing a few laps, we can toggle the “Train” button off, and that will upload the neural network to the second wing, and automatically start driving it based on how it has been trained.
- We can additionally modify the “Epochs” number and “Learning Rate” parameters using their respective sliders to have control of the training of the network.
- After training the wing, we can display its real-time neural network in execution by pressing the “Show Details” button, or by pressing the “f3” key.
- Selecting a wing will automatically save its neural network on the filesystem, and we can load it using the “Load Wing” button.
- The app uses post processing effects for visuals, which can be toggled on/off using the “f2” key to improve performance.

## The Source Code
### Main Directories
- **Assets:** Contains all the image assets and graphics used for the UI.
- **Components:** Contains the reusable components and scenes such as wings, controllers, etc..
- **Scripts:** Contains the scripts written for the Genetic Algorithm and Neural Network logic, using the GDScript programming language (*.gd extension), which is similar to Python.
- **Tracks:** Contains the various track scenes.

### Main Scripts
- **Globals.gd:** Contains variables and controls used globally.
- **scripts/GANN.gd:** Stands for “Genetic Algorithm Neural Networks”, a script containing several functions used to generate, mutate, and perform crossover over Neural Networks.
- **scripts/genetic_controller.gd:** The script that controls all the Genetic Algorithm logic, including mutation, crossover, automatic generation, displaying NNs, fitness, etc…
- **scripts/NN.gd:** A script containing the basic functions to create and train neural networks.
- **scripts/neural_controller.gd:** The script that controls all the Neural Network logic, including training, parameters, displaying NNs, etc…
- **scripts/nn_display.gd:** Script that displays the neural network, provided the input and weights.
- **scripts/wing.gd:** Script that controls the wings, it allows either manually controlling a wing by the player’s keyboard inputs, or have them be controlled by neural networks.
