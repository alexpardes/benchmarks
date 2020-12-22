import std.stdio;
import std.math;
import std.conv;
import std.algorithm.iteration;
import std.datetime;

struct Point
{
	double x;
	double y;

	Vector opBinary(string op)(Point p) if (op == "-")
	{
		return Vector(x - p.x, y - p.y);
	}

	Point opBinary(string op)(Vector v) if (op == "+")
	{
		return Point(x + v.x, y + v.y);
	}
}

struct Vector
{
	double x;
	double y;

	double cross(Vector v)
	{
		return x * v.y - y * v.x;
	}

	double length()
	{
		return sqrt(x * x + y * y);
	}

	Vector normalized()
	{
		return this / length();
	}

	Vector opBinary(string op)(double c) if (op == "*")
	{
		return Vector(c * x, c * y);
	}

	Vector opBinaryRight(string op)(double c) if (op == "*")
	{
		return Vector(c * x, c * y);
	}

	Vector opBinary(string op)(double c) if (op == "/")
	{
		return Vector(x / c, y / c);
	}
}

struct Line
{
	Point p;
	Vector v;

	this(Point p, Vector v)
	{
		this.p = p;
		this.v = v.normalized();
	}

	double intersection_param(Line line)
	{
		auto cross = v.cross(line.v);
		if (cross == 0)
		{
			return double.infinity;
		}

		return (line.p - p).cross(line.v) / cross;
	}
}

struct Segment
{
	Point p1;
	Point p2;

	bool intersects(Segment segment)
	{
		auto line1 = as_line();
		auto line2 = segment.as_line();
		auto param = line1.intersection_param(line2);
		return 0 <= param && param <= length();
	}

	double length()
	{
		return (p2 - p1).length();
	}

	Line as_line()
	{
		return Line(p1, p2 - p1);
	}
}

struct Polygon
{
	Point[] points;

	static new_rect(double left, double top, double width, double height)
	{
		auto right = left + width;
		auto bottom = top + height;
		auto points = [
			Point(left, top), Point(left, bottom), Point(right, bottom),
			Point(right, top),
		];

		return Polygon(points);
	}

	bool intersects(Polygon poly)
	{
		foreach (i; 0 .. points.length)
		{
			foreach (j; 0 .. poly.points.length)
			{
				if (segment(i).intersects(poly.segment(j)))
				{
					return true;
				}
			}
		}

		return false;
	}

	Segment segment(size_t i)
	{
		return Segment(points[i], points[(i + 1) % points.length]);
	}
}

Polygon make_rect(int i)
{
	auto f = to!double(i);
	return Polygon.new_rect(f, f, 100, 100);
}

void main()
{
	Polygon[] polygons;
	foreach (i; 0 .. 1000)
	{
		polygons ~= make_rect(i);
	}

	auto n = 0;

	auto start = MonoTime.currTime;
	foreach (i; 0 .. polygons.length)
	{
		foreach (j; i + 1 .. polygons.length)
		{
			if (polygons[i].intersects(polygons[j]))
			{
				n += 1;
			}
		}
	}

	auto duration = MonoTime.currTime - start;
	writeln(duration);
	writeln(n);
}
