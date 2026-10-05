//+------------------------------------------------------------------+
//|                                                     Geometry.mqh |
//|                                  Copyright 2026, Francis Nyoike. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Francis Nyoike."
#property link      "https://www.mql5.com"
#include "Common.mqh"
//+------------------------------------------------------------------+
//| Pure Mathematical Geometry Calculations                          |
//| Independent of MT5 chart objects, datetime, or ObjectGet values. |
//+------------------------------------------------------------------+
class CGeometry
  {
public:
   //--- Pure Math & Equations
   static double     CalculateSlope(const Point2D &p1, const Point2D &p2);
   static double     GetYAtX(const Point2D &p1, const Point2D &p2, double target_x);
   static double     DistanceToLine(const Point2D &line_p1, const Point2D &line_p2, const Point2D &test_point);

   //--- Spatial & Relationship Tests
   static bool       IsPointAboveLine(const Point2D &line_p1, const Point2D &line_p2, const Point2D &test_point);
   static bool       IsPointOnSegment(const Point2D &line_p1, const Point2D &line_p2, const Point2D &test_point);

   //--- Vector Projection
   static Point2D    ProjectPointOnLine(const Point2D &line_p1, const Point2D &line_p2, const Point2D &test_point);
  };

//+------------------------------------------------------------------+
//| Calculates the slope (m) of a line given two points.             |
//+------------------------------------------------------------------+
static double CGeometry::CalculateSlope(const Point2D &p1, const Point2D &p2)
  {
//--- Prevent division by zero for vertical lines
   if(p2.x == p1.x)
      return 0.0;

   return (p2.y - p1.y) / (p2.x - p1.x);
  }

//+------------------------------------------------------------------+
//| Evaluates y-value at a target x-coordinate using line equation.  |
//+------------------------------------------------------------------+
static double CGeometry::GetYAtX(const Point2D &p1, const Point2D &p2, double target_x)
  {
   if(p2.x == p1.x)
      return p1.y; // Return p1 height if line is vertical

   double m = CalculateSlope(p1, p2);
   return p1.y + m * (target_x - p1.x);
  }

//+------------------------------------------------------------------+
//| Calculates perpendicular distance from a 2D point to a line.     |
//+------------------------------------------------------------------+
static double CGeometry::DistanceToLine(const Point2D &line_p1, const Point2D &line_p2, const Point2D &test_point)
  {
   double dx = line_p2.x - line_p1.x;
   double dy = line_p2.y - line_p1.y;

   double numerator = MathAbs(dy * test_point.x - dx * test_point.y + line_p2.x * line_p1.y - line_p2.y * line_p1.x);
   double denominator = MathSqrt(dx * dx + dy * dy);

   if(denominator == 0.0)
      return 0.0;

   return numerator / denominator;
  }

//+------------------------------------------------------------------+
//|Determines if a test point sits strictly above the line projection|
//+------------------------------------------------------------------+
static bool CGeometry::IsPointAboveLine(const Point2D &line_p1, const Point2D &line_p2, const Point2D &test_point)
  {
   double expected_y = GetYAtX(line_p1, line_p2, test_point.x);
   return (test_point.y > expected_y);
  }

//+------------------------------------------------------------------+
//| Checks if x-coordinate falls between segment boundary points.    |
//+------------------------------------------------------------------+
static bool CGeometry::IsPointOnSegment(const Point2D &line_p1, const Point2D &line_p2, const Point2D &test_point)
  {
   double min_x = MathMin(line_p1.x, line_p2.x);
   double max_x = MathMax(line_p1.x, line_p2.x);

   return (test_point.x >= min_x && test_point.x <= max_x);
  }

//+------------------------------------------------------------------+
//| Projects a point perpendicularly onto the line equation.         |
//+------------------------------------------------------------------+
static Point2D CGeometry::ProjectPointOnLine(const Point2D &line_p1, const Point2D &line_p2, const Point2D &test_point)
  {
   double dx = line_p2.x - line_p1.x;
   double dy = line_p2.y - line_p1.y;

   if(dx == 0.0 && dy == 0.0)
      return line_p1;

   double t = ((test_point.x - line_p1.x) * dx + (test_point.y - line_p1.y) * dy) / (dx * dx + dy * dy);

   Point2D projected;
   projected.x = line_p1.x + t * dx;
   projected.y = line_p1.y + t * dy;

   return projected;
  }

//+------------------------------------------------------------------+
