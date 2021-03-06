%module fortran_naming

%warnfilter(SWIGWARN_LANG_IDENTIFIER);

%fortranbindc_type(MyStruct);

// Without this line, SWIG should raise an error rather than propagating the
// invalid name into the Fortran code.
%rename(FooClass) _Foo;

// Without *this* line, the f_a accessors on Bar will override the _a accessors
// on _Foo, causing Fortran to fail because the argument names of the two
// setters ('arg' and 'f_a') are different.
%rename(f_a_bar) Bar::f_a;

// Without *these* renames, f_x and f_y will appear as duplicates in MyStruct.
%rename(m_x) MyStruct::_x;
%rename(m_y) MyStruct::_y;

%inline %{
// Forward-declare and operate on pointer
class _Foo;
_Foo* identity_ptr(_Foo* f) { return f; }

// Define the class
class _Foo {
  public:
    int _a;
    int _b;
    int _get_a_doubled() const { return _a * 2; }
    int _get_a_doubled(int two) const { return _a * two; }
};

class Bar : public _Foo {
  public:
    int f_a;
};

enum _MyEnum {
    _MYVAL = 1,
};

extern "C" {
struct MyStruct {
    float _x;
    float _y;
    float _z;
    float f_x;
    float f_y;
};

float get_mystruct_y(const MyStruct* ms) { return ms->_y; }
}
%}

%warnfilter(SWIGWARN_FORTRAN_NAME_CONFLICT) f_MyEnum;

// NOTE: these will be ignored because the previous enum will be renamed.
// This behavior is consistent with the other SWIG target languages.
%inline %{
enum f_MyEnum {
    f_MYVAL = 2
};

// Even though the Fortran identifier must be renamed, the function it's
// bound to cannot.
extern "C" int _cboundfunc(const int* _x) { return *_x + 1; }

%}

// This class is poorly named, but the symname is OK.
%inline %{
template<class T>
class _fubar {
  _fubar() { /* */ }
};
%}

%template(foobar) _fubar<int>;
