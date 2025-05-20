import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from scipy.stats import gaussian_kde

# Function to read configuration from a file
def read_config(config_file):
    config = {}
    with open(config_file, 'r') as file:
        for line in file:
            key, value = line.strip().split('=', 1)
            config[key.strip()] = value.strip()
    return config

# Function to read the list of configuration files from a text file
def read_config_files_list(list_file):
    with open(list_file, 'r') as file:
        config_files = [line.strip() for line in file if line.strip()]
    return config_files

# Function to generate 2D density plots
def plot_density(ax, x, y, title, xlabel, ylabel, cmap='viridis'):
    xy = np.vstack([x, y])
    kde = gaussian_kde(xy)
    densities = kde(xy)
    densities_normalized = densities / densities.max()

    sc = ax.scatter(x, y, c=densities_normalized, cmap=cmap, s=10)
#    ax.set_title(title, fontsize=11, fontweight='bold', family='Helvetica')
    ax.set_xlabel(xlabel, fontsize=25, fontweight='bold', family='Helvetica')
    ax.set_ylabel(ylabel, fontsize=25, fontweight='bold', family='Helvetica', labelpad=20)
    ax.tick_params(axis='both', direction='in', length=8, width=3, grid_color='black', grid_alpha=0.5, pad=6)

    # Enable ticks on all sides (top, bottom, left, and right)
    ax.tick_params(axis='x', which='both', top=True, bottom=True)  # Add ticks on both top and bottom for x-axis
    ax.tick_params(axis='y', which='both', left=True, right=True)  # Add ticks on both left and right for y-axis

    # Add title inside the plot at the upper-left corner
    ax.text(0.6, 0.90, title, transform=ax.transAxes, fontsize=20, fontweight='bold', family='Helvetica', verticalalignment='top')

    # Apply bold fontweight to tick labels without affecting tick marks
    for tick in ax.get_xticklabels():
        tick.set_fontweight('bold')
        tick.set_fontsize(20)

    for tick in ax.get_yticklabels():
        tick.set_fontweight('bold')
        tick.set_fontsize(20)

    return sc  # Return the scatter object for the colorbar

# Function to load and validate data files
def load_data_with_logging(data_file):
    try:
        # Try to load the file
        data = np.loadtxt(data_file)
        return data
    except ValueError as e:
        # Log the problematic file and raise the error
        print(f"Error processing file: {data_file}")
        print(f"ValueError: {e}")
        return None

# Read the list of configuration files
config_files_list = read_config_files_list('config_files_list.txt')

# Initialize data and plot parameters
data = []
titles = []
xlabels = []
ylabels = []

# Load data and plot configurations from config files
for config_file in config_files_list:
    config = read_config(config_file)
    data_file = config.get("file_name", None)
    if data_file:
        print(f"Processing file: {data_file}")  # Log each file being processed
        loaded_data = load_data_with_logging(data_file)
        if loaded_data is not None:
            data.append(loaded_data)
            raw_title = config.get("plot_title", "Default Title")
            title = raw_title.replace(r"$\beta$", r"$\mathbf{\beta}$")
            titles.append(title)
            xlabels.append(config.get("x_label", "Default X"))
            ylabels.append(config.get("y_label", "Default Y"))
        else:
            print(f"Skipping file: {data_file}")
    else:
        print(f"Error: No data file specified in {config_file}. Skipping...")

# Define the axis ranges for each plot (min, max)
x_ranges = [(-0.40, 1.00)] * 8   # Replace these with your desired x-axis ranges for each plot

y_ranges = [
    (-1, 45), (-1, 45), (-0.15, 0.5), (-0.15, 0.5),
    (-0.8, 0.05), (-0.8, 0.05), (-1.0, 1.2), (-1.0, 1.2)
]  # Replace these with your desired y-axis ranges for each plot

# Create figure and grid layout for 8 images (4x2 layout)
fig = plt.figure(figsize=(16, 20))  # Adjust figure size as needed
gs = GridSpec(4, 2, figure=fig, width_ratios=[1, 1], wspace=0.04, hspace=0.06)

scatter_plots = []

for i in range(len(data)):
    ax = fig.add_subplot(gs[i // 2, i % 2])
    x = data[i][:, 0]
    y = data[i][:, 1]
    scatter_plots.append(plot_density(ax, x, y, titles[i], xlabels[i], ylabels[i]))

    # Set the thickness of the frame
    for spine in ax.spines.values():
        spine.set_linewidth(2)  # Adjust the value for thicker frames

    ax.set_xlim(x_ranges[i])  # Set x-axis range for plot i
    ax.set_ylim(y_ranges[i])  # Set y-axis range for plot i
    
    # Control y-tick labels
    if i not in [0, 2, 4, 6, 8, 10, 12, 14]:  # Hide y-tick labels for other plots
        ax.tick_params(axis='y', labelleft=False)
    else:
        ax.tick_params(axis='y', labelleft=True)  # Ensure y-tick labels are shown

    # Control x-tick labels
    if i not in [6, 7]:  # Hide x-tick labels for other plots
        ax.tick_params(axis='x', labelbottom=False)
    else:
        ax.tick_params(axis='x', labelbottom=True)  # Ensure x-tick labels are shown

    # Customize x-axis tick positions based on the plot index
    if i in [6, 7]:  # For plots 1, 2, 5, 6, 9, 10, 13, 14 (0-based indices)
        ax.set_xticks([-0.2, 0.0, 0.2, 0.4, 0.6, 0.8])

    # Customize y-axis tick positions based on the plot index
    if i in [4, 5]:  # For plots 1, 2, 5, 6, 9, 10, 13, 14 (0-based indices)
        ax.set_yticks([-0.8, -0.6, -0.4, -0.2, 0.0])
    elif i in [6, 7]:  # For plots 3, 4, 7, 8, 11, 12, 15, 16 (0-based indices)
        ax.set_yticks([-1.0, -0.5, 0.0, 0.5, 1.0])

    # Remove x-axis tick labels for the first 6 plots
    if i < 6:
        ax.set_xticklabels([])

    # Remove y-tick labels for 2nd, 4th, 6th, and 8th plots (index 1, 3, 5, 7)
    if (i + 1) % 2 == 0:  # These are the 2nd, 4th, 6th, and 8th plots
        ax.set_yticklabels([])  # Remove y-tick labels

    # Ensure consistent label positioning using labelpad and adjusting position for visibility
    ax.yaxis.label.set_position(('outward', 20))  # Move the label outward by 20 units for all plots
    ax.yaxis.set_label_coords(-0.14, 0.5)  # Fine-tune the label position

# Add colorbar
cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])  # Adjust position [left, bottom, width, height]
cbar = fig.colorbar(scatter_plots[0], cax=cbar_ax, orientation="vertical")

# Increase font size of colorbar label
cbar.set_label("Density", fontsize=25, fontweight="bold", family="Helvetica")  

# Increase font size of colorbar tick labels
cbar.ax.tick_params(labelsize=20, width=2, length=8)
for label in cbar.ax.get_yticklabels():
    label.set_fontweight("bold")  # Make tick labels bold

plt.savefig("density_plots_layout_8.png", dpi=300, bbox_inches="tight")
plt.show()
