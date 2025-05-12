#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 14 13:29:03 2024
"""


import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import math

df = pd.read_excel('J_COUPLING_IDP_checked.xlsm',sheet_name='AB42_EXP')
#df = pd.read_excel('J_COUPLING_IDP_checked.xlsm',sheet_name='AB42_SERVER')
#df = pd.read_excel('J_COUPLING_IDP_checked.xlsm',sheet_name='tau43_server')
#df = pd.read_excel('J_COUPLING_IDP_checked.xlsm',sheet_name='tau43_exp')
#df = pd.read_excel('J_COUPLING_IDP_checked.xlsm',sheet_name='amylin_server')
#df = pd.read_excel('J_COUPLING_IDP_checked.xlsm',sheet_name='alpha_syn_exp')
#df = pd.read_excel('J_COUPLING_IDP_checked.xlsm',sheet_name='alpha_syn_server')
#print(df)
MAE_table = []
MSE_table = []
fd_table = []
cosine = []
FF = []
slopes = []
intercepts = []
i = 1
for i in range(1, len(df.columns)):
    if i < 2:
        exp = pd.to_numeric(df.iloc[:, i])

    if i > 1:
        sim = pd.to_numeric(df.iloc[:, i])
        # Calculate correlation coefficient
        correlation_coefficient = np.corrcoef(exp,sim)[0, 1]
                
        # Create a scatter plot
        plt.scatter(exp,sim, color='blue', label='Data points')
        
        ############################################################################
         
        # Calculate correlation coefficient
        correlation_coefficient_fit = np.corrcoef(exp,sim)[0, 1]

        print(f"Correlation coefficient of fitted line: {correlation_coefficient_fit}")
        # Fit a linear regression line
        slope, intercept = np.polyfit(exp,sim, 1)
        slopes.append(slope)
        intercepts.append(intercept)
        # Plot the regression line with fitted line
        regression_line_fit = np.polyval([slope, intercept], exp)
        plt.plot(exp, regression_line_fit, color='green', label=f'Regression Line (y = {slope:.2f}x + {intercept:.2f})')

    
         # Calculate the sum of squared residuals (SSR)
        residuals = sim - regression_line_fit
        ssr = np.sum(residuals**2)

        # Calculate the total sum of squares (SST)
        sst = np.sum((sim - np.mean(sim))**2)

        # Calculate R-squared
        r_squared = 1 - (ssr / sst)

        print(f"R-squared value of fitted line: {r_squared}")


        # Mean Squared Error 
        MSE_fit = np.sum((sim-regression_line_fit)**2)/len(sim)
        print(f"MSE value of fitted line: {MSE_fit}")

        #Mean Absolute Error
        MAE_fit = np.sum(abs(sim-regression_line_fit))/len(sim)
        print(f"MAE value of fitted line: {MAE_fit}")
        ###############################################################################3
        
        # Desired slope and intercept
        desired_slope = 1
        desired_intercept = 0
        
        # Plot the regression line with the desired slope and intercept
        regression_line_0 = np.polyval([desired_slope, desired_intercept], exp)
        plt.plot(exp, regression_line_0, color='red', label=f'Regression Line (y = {desired_slope:.2f}x + {desired_intercept:.2f})')

        # Set labels and legend
        #plt.xlabel('Experimental',fontsize=20 )
        #plt.xlabel('Server',fontsize=20 )
        #plt.ylabel('Simulation',fontsize=20)

        #plt.title( f'{df.columns[i]}:α-Synuclein',fontsize=20)
        #plt.title( f'{df.columns[i]}:α-Synuclein Server',fontsize=20)
        plt.title( f'{df.columns[i]}:Aβ42',fontsize=20)
        #plt.title( f'{df.columns[i]}:Aβ42 Server',fontsize=20)
        #plt.title( f'{df.columns[i]}:Tau43 Server',fontsize=20)
        #plt.title( f'{df.columns[i]}:Tau43',fontsize=20)
        #plt.title( f'{df.columns[i]}:Amylin Server',fontsize=20)
        
        plt.xlim(5.25,9.75)
        plt.ylim(4.5,9)

        plt.xticks(fontsize=12)
        plt.yticks(fontsize=12)
        #plt.legend()  
        
        title = plt.gca().get_title()
        
       # Clean up the strings to make them file-system safe (remove spaces and special characters)
        title_safe = title.replace(" ", "_").replace("/", "_")
        
        # Combine to create a filename
        filename = f"{title_safe}.png"

        plt.gca().title.set_visible(False)
                  
        plt.tick_params(axis="x", direction="in")
        plt.tick_params(axis="y", direction="in")
        plt.savefig(filename, dpi=300,format='png') 
        plt.close()
        # Show the plot
        plt.show()
        
        fractional_dev = (exp - sim)/exp
        fract_dev_mod = abs(exp - sim)/exp
        print(f"mean fractional_dev: {np.mean(fract_dev_mod)}")
        fd_table.append(round(np.mean(fract_dev_mod),2))
        
        plt.plot(fractional_dev, marker='o', linestyle='-', color='b') 
        
        plt.axhline(y=0, color='black', linestyle='--', linewidth=1)
        # Desired slope and intercept
        desired_slope = 1
        desired_intercept = 0
 
        # Plot the regression line with the desired slope and intercept
        regression_line_0 = np.polyval([desired_slope, desired_intercept], df.iloc[:, 1] )
        
        # Mean Squared Error 
        MSE = np.sum((df.iloc[:, i]-regression_line_0)**2)/len(df.iloc[:, i])
        print(f"MSE value: {MSE}")
        MSE_table.append(MSE)
        
        #Mean Absolute Error
        MAE = np.sum(abs(df.iloc[:, i]-regression_line_0))/len(df.iloc[:, i])
        print(f"MAE value: {MAE}")
        MAE_table.append(MAE)
        
        # Calculate the tangent of the angle
        tan_theta = abs(slope - desired_slope) / (1 + slope * desired_slope)
        
        # Calculate the angle in radians
        theta = math.atan(tan_theta)
        
        # Convert radians to degrees
        theta_degrees = round(math.degrees(theta),2)
        
        # Calculate the cosine of the angle
        cos_theta = round(math.cos(theta),3)
        
        cosine.append(cos_theta)
        FF.append(df.columns[i])
        
        # Output the results
        print(f"Angle (degrees): {theta_degrees:.2f}")
        print(f"Cosine of the angle: {cos_theta:.4f}")
                
        # Add labels and title
        #plt.xlabel('Residue',fontsize=20)
        #plt.ylabel('|(exp - sim)/exp|',fontsize=20)
        
        #plt.ylabel('(server - sim)/server',fontsize=20)
        #plt.ylabel('(exp - sim)/exp',fontsize=20)
        plt.ylabel('FD')
        #plt.ylim(-0.65,0.55)
        #plt.suptitle('Fractional deviation per residue')
        
        #plt.title( f'{df.columns[i]}:Amylin Server',fontsize=20)
        plt.title( f'{df.columns[i]}:Aβ42',fontsize=20)
        #plt.title( f'{df.columns[i]}:Aβ42 Server',fontsize=20)
       # plt.title( f'{df.columns[i]}:Tau43 Server',fontsize=20)
        #plt.title( f'{df.columns[i]}:Tau43',fontsize=20)
        #plt.title( f'{df.columns[i]}:α-Synuclein',fontsize=20)
        #plt.title( f'{df.columns[i]}:α-Synuclein Server',fontsize=20)
        
        #plt.subplots_adjust(top=0.9)
        
        #plt.text(0,-0.4 ,f"mean fractional_dev: {np.mean(fract_dev_mod):.2f}" ,color='black', fontsize=15)
        #plt.text(0,-0.45 , f'MSE value: {MSE:.2f}', color='black', fontsize=15)
        #plt.text(0,-0.5 , f'MAE value: {MAE:.2f}', color='black', fontsize=15)
        #plt.text(0,-0.55,f"correlation_coefficient: {correlation_coefficient:.2f}" ,color='black', fontsize=15)
        #plt.text(0,-0.6,f"Theta, Cosine of the angle: {theta_degrees:.2f}, {cos_theta:.3f}", color='black', fontsize=15)
               
        # Show the plot
        plt.xticks(fontsize=12)
        plt.yticks(fontsize=12)
        #plt.legend(fontsize=18)  
        
        title = plt.gca().get_title()
        ylabel = plt.gca().get_ylabel()

        plt.ylim(-0.45,0.45)

        # Clean up the strings to make them file-system safe (remove spaces and special characters)
        title_safe = title.replace(" ", "_").replace("/", "_")
        ylabel_safe = ylabel.replace(" ", "").replace("/", "")

        # Combine to create a filename
        filename = f"{title_safe}_{ylabel_safe}.png"

        plt.gca().title.set_visible(False)
        plt.gca().yaxis.label.set_visible(False)
        # Save the plot with the dynamic filename
          
        plt.tick_params(axis="x", direction="in")
        plt.tick_params(axis="y", direction="in")
        plt.savefig(filename, dpi=300,format='png')
        plt.close()
        plt.show() 

data = {'Force feild-Water model': FF, 'cos θ':cosine, 'MSE':MSE_table, 'MAE':MAE_table, 'fract dev':fd_table}
data1 = {'Force feild-Water model': FF, 'slope':slopes, 'intercept':intercepts}
theta_table = pd.DataFrame(data)
reg_table = pd.DataFrame(data1)
print(theta_table)
print(reg_table)              

        
