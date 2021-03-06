! File : inctest_runme.f90

program inctest_runme
  use inctest
  use ISO_C_BINDING
  implicit none
  ! If the 'includes' fail, these will produce compiler errors
  type(A) :: ai
  type(B) :: bi

  ai = A()
  call ai%release()

  bi = B()
  call bi%release()
  
  if (importtest1(5) /= 15) stop 1
  if (importtest2("black") /= "white") stop 1

end program


