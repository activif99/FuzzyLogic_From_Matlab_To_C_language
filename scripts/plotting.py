import matplotlib.pyplot as plt
import pandas as pd


# Load data
data = pd.read_csv("C:/Users/univ/Desktop/stadiz/(PROJET)PFS_FuzzyLogic/results.csv")


# Plot
plt.plot(data["Time"], data["Coefficient"], label="Coefficient vs Time")
plt.xlabel("Time (s)")
plt.ylabel("Motor Coefficient")
plt.title("Motor Coefficient Over Time using C")
plt.grid(True)
plt.legend()
plt.show()

