import math
import doctest

class Point:
    """
    This is a class for 2D points.

    >>> p = Point(3, 4)
    >>> print(p)
    Point(3, 4)
    >>> p1 = p.delta_x(10)
    >>> print(p1)
    Point(13, 4)
    >>> p2 = p.delta_y(-10)
    >>> print(p2)
    Point(3, -6)
    >>> p3 = p.translate(5, -5)
    >>> print(p3)
    Point(8, -1)
    
    
    """

    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y

    def __repr__(self):
        return f"Point({self.x}, {self.y})"

    def delta_x(self, dx):
        return Point(self.x + dx, self.y)

    def delta_y(self, dy):
        return Point(self.x, self.y + dy)

    def translate(self, dx, dy):
        return Point(self.x + dx, self.y + dy)


class Circle:
    """
    This is a class for circles.

    >>> c = Circle(Point(0, 0), 10)
    >>> print(c)
    Circle(Point(0, 0), 10)
    >>> c1 = c.translate(-3.14, +12.2)
    >>> print(c1)
    Circle(Point(-3.14, 12.2), 10)
    >>> round(c1.perimeter(), 2)
    62.83
    >>> round(c1.area(), 2)
    314.16
    """

    def __init__(self, center=Point(), radius=0):
        self.center = center
        self.radius = radius

    def __repr__(self):
        return f"Circle({self.center}, {self.radius})"

    def area(self):
        return math.pi * self.radius**2

    def perimeter(self):
        return 2 * math.pi * self.radius

    def translate(self, dx, dy):
        new_center = self.center.translate(dx, dy)
        return Circle(new_center, self.radius)


class Rectangle:
    """
    This is a class for rectangles.

    >>> r = Rectangle(Point(5, 5), Point(1, -1))
    >>> print(r)
    Rectangle(Point(1, 5), Point(5, -1))
    >>> r1 = r.translate(-11, +3.14)
    >>> print(r1)
    Rectangle(Point(-10, 8.14), Point(-6, 2.14))
    >>> r1.perimeter()
    20.0
    >>> r1.area()
    24.0
    """

    def __init__(self, upper_left=Point(), lower_right=Point()):
        self.upper_left = Point(min(upper_left.x, lower_right.x), max(upper_left.y, lower_right.y))
        self.lower_right = Point(max(upper_left.x, lower_right.x), min(upper_left.y, lower_right.y))

    def __repr__(self):
        return f"Rectangle({self.upper_left}, {self.lower_right})"

    def area(self):
        width = self.lower_right.x - self.upper_left.x
        height = self.upper_left.y - self.lower_right.y
        return abs(width * height)

    def perimeter(self):
        width = self.lower_right.x - self.upper_left.x
        height = self.upper_left.y - self.lower_right.y
        return abs(2 * (width + height))

    def translate(self, dx, dy):
        new_upper_left = self.upper_left.translate(dx, dy)
        new_lower_right = self.lower_right.translate(dx, dy)
        return Rectangle(new_upper_left, new_lower_right)


if __name__ == "__main__":
    doctest.testmod(verbose=True)
