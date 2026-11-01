//+------------------------------------------------------------------+
//| MatrixSolver.mqh                                                 |
//+------------------------------------------------------------------+
#property copyright "Adesewa"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Purpose                                                          |
//| Hand-rolled, dependency-free linear algebra used by              |
//|   CLSMExitEngine to fit the cross-sectional regression at every  |
//|   backward-induction step of the Longstaff-Schwartz algorithm. No|
//|   ALGLIB, no external DLLs - everything below is plain MQL5      |
//|   arithmetic on native arrays.                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| SolveOLS                                                         |
//| Fits beta in y ~ X*beta by forming the normal equations (X'X +   |
//|   lambda*I) * beta = X'y and solving them with Gauss-Jordan      |
//|   elimination and partial pivoting.                              |
//|                                                                  |
//| X      : design matrix, rows x cols, one row per in-the-money    |
//|   path                                                           |
//| y      : target vector (discounted realized continuation         |
//|   cashflow)                                                      |
//| lambda : ridge penalty - protects the fit when the number of in- |
//|   the-money paths at a given step is small relative to the number|
//|   of basis terms, which would otherwise leave X'X singular or    |
//|   numerically unstable                                           |
//| beta   : output coefficients, length cols                        |
//|                                                                  |
//| Returns false if the augmented system could not be pivoted       |
//|   (every candidate pivot below eps), signalling the caller to    |
//|   fall back to "always continue" for that step rather than trust |
//|   a degenerate fit.                                              |
//+------------------------------------------------------------------+
bool SolveOLS(const double &X[][6],
              const double &y[],
              const int     rows,
              const int     cols,
              const double  lambda,
              double       &beta[])
  {
//--- guard: require at least as many in-the-money paths as basis
//--- terms. Ridge regularization can, in principle, still produce a
//--- solution with fewer rows than columns, so this is a deliberate
//--- reliability choice rather than a mathematical necessity - a fit
//--- built from fewer observations than free parameters is not
//--- trusted to drive a real exit decision here, whatever it solves to
   if(rows < cols)
      return(false);

//--- build the symmetric cols x cols Gram matrix XtX and the
//--- cols-length vector Xty by direct summation; this is the
//--- classic normal-equation formulation, cheap here because cols
//--- is fixed and small (the basis has at most 6 terms)
   double xtx[6][6];
   double xty[6];
   for(int a = 0; a < cols; a++)
     {
      xty[a] = 0.0;
      for(int b = 0; b < cols; b++)
         xtx[a][b] = 0.0;
     }

   for(int r = 0; r < rows; r++)
     {
      for(int a = 0; a < cols; a++)
        {
         //--- accumulate X'y for this row's contribution
         xty[a] += X[r][a] * y[r];
         for(int b = 0; b < cols; b++)
            xtx[a][b] += X[r][a] * X[r][b];
        }
     }

//--- add the ridge penalty to the diagonal only; this shrinks the
//--- coefficients toward zero and, critically, guarantees a
//--- strictly positive diagonal even when a basis column is nearly
//--- collinear with another (e.g. pnl and pnl^2 on a narrow path
//--- sample), which is what actually causes Gauss-Jordan to fail
   for(int a = 0; a < cols; a++)
      xtx[a][a] += lambda;

//--- build the augmented matrix [xtx | xty] to solve in place
   double aug[6][7];
   for(int a = 0; a < cols; a++)
     {
      for(int b = 0; b < cols; b++)
         aug[a][b] = xtx[a][b];
      aug[a][cols] = xty[a];
     }

//--- forward elimination with partial pivoting: at each column,
//--- swap in the row with the largest absolute entry in that
//--- column to avoid dividing by a near-zero pivot, which is the
//--- usual source of exploding coefficients in naive Gauss-Jordan
   double eps = 1.0e-12;
   for(int col = 0; col < cols; col++)
     {
      int    pivot_row = col;
      double pivot_val = MathAbs(aug[col][col]);
      for(int r = col + 1; r < cols; r++)
        {
         if(MathAbs(aug[r][col]) > pivot_val)
           {
            pivot_val = MathAbs(aug[r][col]);
            pivot_row = r;
           }
        }
      if(pivot_val < eps)
         return(false);            //--- system too degenerate to trust

      if(pivot_row != col)
        {
         for(int c = 0; c <= cols; c++)
           {
            double tmp        = aug[col][c];
            aug[col][c]       = aug[pivot_row][c];
            aug[pivot_row][c] = tmp;
           }
        }

      //--- normalize the pivot row so aug[col][col] becomes 1.0
      double piv = aug[col][col];
      for(int c = 0; c <= cols; c++)
         aug[col][c] /= piv;

      //--- eliminate this column from every other row (full
      //--- Gauss-Jordan, not just below the pivot) so the final
      //--- augmented column is the solution directly, with no
      //--- separate back-substitution pass required
      for(int r = 0; r < cols; r++)
        {
         if(r == col)
            continue;
         double factor = aug[r][col];
         for(int c = 0; c <= cols; c++)
            aug[r][c] -= factor * aug[col][c];
        }
     }

//--- read off the solution from the last augmented column
   ArrayResize(beta, cols);
   for(int a = 0; a < cols; a++)
      beta[a] = aug[a][cols];

   return(true);
  }
//+------------------------------------------------------------------+
