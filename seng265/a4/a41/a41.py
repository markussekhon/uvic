#!/usr/bin/env python
"""Assignment 4 Part 1"""

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


def main() -> None:
    """main() method that generates the art"""
    # define the shapes
    shapes = [
        CircleShape(255, 0, 0, 0.25, 50, 50, 50),
        RectangleShape(0, 255, 0, 0.5, 100, 0, 100, 100),
        CircleShape(0, 0, 255, 0.75, 250, 50, 50),
    ]

    # create the svg canvas
    canvas = SvgCanvas(500, 300, shapes)

    # create the html document
    doc = HtmlDocument("My Art", canvas)

    # write the document to a file
    doc.write_to_file("a41.html")


if __name__ == "__main__":
    main()
