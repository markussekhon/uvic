#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 8 14:44:33 2023
Based on: https://www.kaggle.com/datasets/arbazmohammad/world-airports-and-airlines-datasets
@author: rivera
@author: Markus Sekhon V00000000
"""
import pandas as pd
import argparse

def extract_arguments() -> argparse.Namespace:
    """ extracts arguments from CLI
            Parameters
            ----------
                none

            Returns
            -------
                argparse.Namespace
                    A structure holding:
                    - sortby: str of criteria
                    - display: str of num of items to display
                    - files: str of files to process
    """
    args = argparse.ArgumentParser()
    args.add_argument('--sortBy')
    args.add_argument('--display')
    args.add_argument('--files')
    return args.parse_args()

def construct_data(filenames) -> pd.DataFrame:
    """ constructs dataframe based on what was passed as file input, combines if necessary
            Parameters
            ----------
                none

            Returns
            -------
                pd.DataFrame
    """

    dataframes = [pd.read_csv(file) for file in filenames.split(',')]
    return pd.concat(dataframes, ignore_index=True) #list of dataframes turned into one with non repeating indicies

def sort_data(data, sort) -> pd.DataFrame:
    """ sorts a dataframe passed to it by the sort specifications
            Parameters
            ----------
                data: pd.DataFrame 
                sort: str

            Returns
            -------
                pd.DataFrame
    """

    return data.sort_values(by = [sort,'song'], ascending = [False,False])

def extract_data(data, top) -> pd.DataFrame:
    """ chops a dataframe up by number passed in top
            Parameters
            ----------
                data: pd.DataFrame 
                top: int

            Returns
            -------
                pd.DataFrame
    """

    return data.head(top)

def data_to_csv(data, sort_by) -> None:
    """ takes a dataframe and outputs a csv file with only artist, song, year,
            Parameters
            ----------
                data: pd.DataFrame
                sort_by: str 

            Returns
            -------
                nothing
    """
    columns = ['artist','song','year']
    columns.append(sort_by)
    data[columns].to_csv('output.csv',index=False)

def main():
    """Main entry point of the program."""

    args = extract_arguments()
    data = construct_data(args.files)
    data = sort_data(data,args.sortBy)
    data = extract_data(data,int(args.display))
    data_to_csv(data,args.sortBy)

if __name__ == '__main__':
    main()