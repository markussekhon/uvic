#!/usr/bin/env python
"""Assignment 4 Part 2"""

import random


class PyArtConfig:
    """PyArtConfig class used to store range values to generate random art"""

    def __init__(self):
        """contructer of the PyArtConfig object that defines the ranges directly"""
        self.shape_range = (0, 3)  # 0: circle, 1: rectangle, 2/3: ellipse
        self.x_range = (0, 500)  # x coordinate range in viewport
        self.y_range = (0, 500)  # y coordinate range in viewport
        self.circle_radius_range = (10, 100)
        self.ellipse_rx_range = (10, 30)
        self.ellipse_ry_range = (10, 30)
        self.rect_width_range = (10, 100)
        self.rect_height_range = (10, 100)
        self.red_range = (0, 255)
        self.green_range = (0, 255)
        self.blue_range = (0, 255)
        self.opacity_range = (0.0, 1.0)

    def get_random_shape(self):
        """
        get_random_shape() method that uses ranges 
        of object to generate values for shape
        """
        shape = random.randint(*self.shape_range)
        x = random.randint(*self.x_range)
        y = random.randint(*self.y_range)

        if shape == 0:  # circle
            rad = random.randint(*self.circle_radius_range)
            return (shape, x, y, rad, 0, 0, 0, 0)

        elif shape == 1:  # rectangle
            w = random.randint(*self.rect_width_range)
            h = random.randint(*self.rect_height_range)
            return (shape, x, y, 0, 0, 0, w, h)

        else:  # ellipse
            shape = 3 # keep all ellipses as 3 per the outline
            rx = random.randint(*self.ellipse_rx_range)
            ry = random.randint(*self.ellipse_ry_range)
            return (shape, x, y, 0, rx, ry, 0, 0)

    def get_random_color(self):
        """
        get_random_color() method for PyArtConfig
        that generates random rgb values from object ranges
        """
        r = random.randint(*self.red_range)
        g = random.randint(*self.green_range)
        b = random.randint(*self.blue_range)
        return (r, g, b)

    def get_random_opacity(self):
        """
        get_random_opacity() method for PyArtConfig
        that generates random rounded opacity value
        """
        return round(random.uniform(*self.opacity_range), 1)


class RandomShape:
    """
    RandomShape class that uses PyArtConfig class
    to generate random shapes to create art
    """
    def __init__(self, config: PyArtConfig, count: int):
        """constructer for RandomShape objects"""
        self.config = config
        self.count = count
        self.shape, self.x, self.y, self.rad, self.rx, self.ry, self.w, self.h = self.config.get_random_shape()
        self.r, self.g, self.b = self.config.get_random_color()
        self.opacity = self.config.get_random_opacity()

    def as_part2_line(self):
        """as_part2_line() method that formats the information to present"""
        return "{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}".format(
            self.count, self.shape, self.x, self.y, self.rad, self.rx, self.ry,
             self.w, self.h, self.r, self.g, self.b, self.opacity)


def main():
    """main() method that generates values for the art"""
    
    # define ranges for random shape generation
    config = PyArtConfig()

    # generate 10 shapes
    shapes = [RandomShape(config, count) for count in range(10)]
    
    # headers to explain the information being displayed on cli
    print("{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}{:>4}".format(
        'CNT', 'SHA', 'X', 'Y', 'RAD', 'RX', 'RY', 'W', 'H', 'R', 'G', 'B', 'OP'))
    
    # displaying the randomly generates values
    for shape in shapes:
        print(shape.as_part2_line())


if __name__ == "__main__":
    main()
