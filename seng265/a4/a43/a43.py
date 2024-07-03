#!/usr/bin/env python
"""Assignment 4 Part 3"""

import random

from typing import NamedTuple, List, Union


class CircleShape(NamedTuple):
    """CircleShape class to create svg"""

    red: int
    blue: int
    green: int
    opacity: float
    x: int
    y: int
    rad: int

    def render(self) -> str:
        """render() method for CircleClass that generates svg"""
        return (
            f'        <circle cx="{self.x}" cy="{self.y}" r="{self.rad}" '
            f'fill="rgb({self.red},{self.green},{self.blue})" '
            f'fill-opacity="{self.opacity}"></circle>\n'
        )


class RectangleShape(NamedTuple):
    """RectangleShape class to create svg"""

    red: int
    blue: int
    green: int
    opacity: float
    x: int
    y: int
    width: int
    height: int

    def render(self) -> str:
        """render() method for RectangleShape to generate svg"""
        return(
            f'        <rect x="{self.x}" y="{self.y}" width="{self.width}" height="{self.height}" ' 
            f'fill="rgb({self.red},{self.green},{self.blue})" '
            f'fill-opacity="{self.opacity}"></rect>\n'
        )
    

class EllipseShape(NamedTuple):
    """EllipseShape class to create svg"""

    red: int
    blue: int
    green: int
    opacity: float
    x: int
    y: int
    rx: int
    ry: int

    def render(self) -> str:
        """render() method for EllipseShape to generate svg"""
        return (
            f'        <ellipse cx="{self.x}" cy="{self.y}" rx="{self.rx}" ry="{self.ry}" '
            f'fill="rgb({self.red},{self.green},{self.blue})" '
            f'fill-opacity="{self.opacity}"></ellipse>\n'
        )


class HtmlComponent:
    """HtmlComponent class to dictate requirements"""

    def render(self) -> str:
        """render() method must exist for any subclass of HtmlComponent"""
        pass


class SvgCanvas(HtmlComponent):
    """SvgCanvas class to create canvas and generate art"""

    def __init__(self, width: int, height: int, shapes: List[Union[CircleShape, RectangleShape]]) -> None:
        """constructer for SvgCanvas object"""
        self.width = width
        self.height = height
        self.shapes = shapes

    def gen_art(self) -> str:
        """gen_art() methood for SvgCanvas objects"""
        svg = f'    <svg width="{self.width}" height="{self.height}">\n'
        for shape in self.shapes:
            svg += shape.render()
        svg += '    </svg>\n'
        return svg

    def render(self) -> str:
        """render() method that just uses gen_art() lol"""
        return self.gen_art()


class HtmlDocument:
    """HtmlDocument class to generate document"""

    def __init__(self, title: str, svg: SvgCanvas) -> None:
        """constructer for HtmlDocument class"""
        self.title = title
        self.svg = svg

    def write_to_file(self, filename: str) -> None:
        """write_to_file() method for HtmlDocument objects"""
        with open(filename, 'w') as f:
            f.write("<html>\n<head>\n")
            f.write(f"    <title>{self.title}</title>\n</head>\n<body>\n")
            f.write(self.svg.render())
            f.write("</body>\n</html>\n")


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

    def create_shape_object(self):
        """create_shop_object() method that uses values generated to create ShapeObjects"""

        if self.shape == 0:
            return CircleShape(self.r, self.g, self.b, self.opacity, self.x, self.y, self.rad)
        
        elif self.shape == 1:
            return RectangleShape(self.r, self.g, self.b, self.opacity, self.x, self.y, self.w, self.h)

        else:
            return EllipseShape(self.r, self.g, self.b, self.opacity, self.x, self.y, self.rx, self.ry)


class ArtGenre:
    """ArtGenre class that uses rng to pick between random ranges"""
    
    def __init__(self):
        """constructer that has the ranges defines"""
        self.genre_one = (0,10)
        self.genre_two = (50,100)
        self.genre_three = (1000,2500)
        self.which_genre = random.randint(1,3)

    def pick(self):
        """pick() method to select the ranges"""

        if self.which_genre == 1:
            return random.randint(*self.genre_one)

        elif self.which_genre == 2:
            return random.randint(*self.genre_two)

        else:
            return random.randint(*self.genre_three)


def main() -> None:
    """main() method that generates 3 random art pieces"""

    # ranges defined for shapes
    config = PyArtConfig()

    # art piece 1
    genre = ArtGenre().pick()
    shapes = [RandomShape(config, count).create_shape_object() for count in range(genre)]
    canvas = SvgCanvas(500, 500, shapes)
    doc = HtmlDocument("My Randomly Generated Art", canvas)
    doc.write_to_file("a431.html")

    # art piece 2
    genre = ArtGenre().pick()
    shapes = [RandomShape(config, count).create_shape_object() for count in range(genre)]
    canvas = SvgCanvas(500, 500, shapes)
    doc = HtmlDocument("My Randomly Generated Art", canvas)
    doc.write_to_file("a432.html")

    # art piece 3
    genre = ArtGenre().pick()
    shapes = [RandomShape(config, count).create_shape_object() for count in range(genre)]
    canvas = SvgCanvas(500, 500, shapes)
    doc = HtmlDocument("My Randomly Generated Art", canvas)
    doc.write_to_file("a433.html")


if __name__ == "__main__":
    main()
