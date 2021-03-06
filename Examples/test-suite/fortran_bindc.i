%module fortran_bindc

%rename(RenamedOtherStruct) OtherStruct;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK) SimpleStruct::s; /* Setting a const char * variable may leak memory. */

// Treat the struct as a native fortran struct rather than as a class with
// getters/setters.
%fortranbindc_type(OtherStruct);
%fortranbindc_type(SimpleStruct);
%fortranbindc set_val;
%fortranbindc set_ptr;
%fortranbindc get_ptr_arg;
%fortranbindc get_ptr;
%fortranbindc get_val;
%fortranbindc get_cptr;
%fortranbindc get_handle;

// Bind some global variables
%fortranbindc my_global_int;
%fortranbindc my_const_global_int;

// XXX: currently C-bound globals are not implemented.
// See https://github.com/sethrj/swig/issues/73
%ignore my_global_int;
%ignore my_const_global_int;

%inline %{

typedef double (*BinaryOp)(double x, double y);

#ifdef __cplusplus
struct Foo;
#endif

typedef struct {
  int j;
  int k;
} OtherStruct;

typedef struct {
  int i;
  double d;
  char c;
  BinaryOp funptr;
  void* v;
  const char* s;
  OtherStruct o;
  float p[3];
  // Foo f // uncommenting will produce an error in Fortran since 'Foo' is a
  // class and not POD
} SimpleStruct;
%}

%{
  static SimpleStruct global_struct = {0,0,0,0,0,0,{0,0},{0,0,0}};
  static SimpleStruct* global_struct_ptr = 0;
%}

%inline %{

#ifdef __cplusplus
void set_ref(const SimpleStruct& s) {global_struct = s; }
void get_ref_arg(SimpleStruct& s) { s = global_struct; }
SimpleStruct& get_ref() { return global_struct; }
const SimpleStruct& get_cref() { return global_struct; }

extern "C" {
#endif

void set_val(SimpleStruct s) { global_struct = s; }
void set_ptr(const SimpleStruct* s) { global_struct = *s; }
void get_ptr_arg(SimpleStruct* s) { *s = global_struct; }
SimpleStruct get_val() { return global_struct; }
SimpleStruct* get_ptr() { return &global_struct; }
const SimpleStruct* get_cptr() { return &global_struct; }
SimpleStruct** get_handle() { return &global_struct_ptr; }

int my_global_int;
extern const int my_const_global_int;

#ifdef __cplusplus
}
#endif
%}

%{
#ifdef __cplusplus
extern "C" const int my_const_global_int = 9;
#endif
%}

%fortranconst is_cplusplus;
#ifdef __cplusplus
%constant int is_cplusplus = 1;
#else
%constant int is_cplusplus = 0;
#endif

%fortranbindc_type(AB);
%fortranbindc_type(XY);

%include <carrays.i>

%array_functions(int,intArray);
%array_class(double, doubleArray);
%array_class(short, shortArray);

%inline %{
typedef struct {
  int x;
  int y;
} XY;
XY globalXYArray[3];

typedef struct {
  int a;
  int b;
} AB;

AB globalABArray[3];
%}

%array_class(XY, XYArray)
%array_functions(AB, ABArray)

%inline %{
short sum_array(short x[5]) {
  short sum = 0;
  int i;
  for (i=0; i<5; i++) {
    sum = sum + x[i];
  }
  return sum;
}
%}

