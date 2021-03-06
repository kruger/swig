/* File : stdvec.cxx */

#include "stdvec.h"

#include <iostream>
using std::cout;
using std::endl;

/* -------------------------------------------------------------------------
 * FREE FUNCTIONS
 * ------------------------------------------------------------------------- */

template<class T>
void print_vec(const std::vector<T> &v) {
  print_view<T>(make_const_view(v));
}

template<class T>
void print_view(std::pair<const T *, size_t> view) {
  cout << "{";
  const T *iter = view.first;
  const T *end = iter + view.second;
  if (iter != end) {
    cout << *iter++;
  }
  while (iter != end) {
    cout << ", " << *iter++;
  }
  cout << "}" << endl;
}

/* -------------------------------------------------------------------------
 * EXPLICIT INSTANTIATION
 * ------------------------------------------------------------------------- */

template void print_vec(const std::vector<double> &);
template void print_view(std::pair<const double *, size_t>);



