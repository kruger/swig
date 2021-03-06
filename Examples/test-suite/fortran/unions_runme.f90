! File : unions_runme.f90

program unions_runme
  use unions
  use ISO_C_BINDING
  implicit none
  type(SmallStruct) :: small
  type(BigStruct) :: big
  type(EmbeddedUnionTest) :: eut
  integer(C_INT) :: Num1
  ! TODO: Fortran doesn't support nested unions (warning 38)

  ! Create new instances of SmallStruct and BigStruct for later use
  small = SmallStruct()
  call small%set_jill(200_C_SHORT)

  big = BigStruct()
  call big%set_smallstruct(small)
  call big%set_jack(300_C_INT)

  ! Use SmallStruct then BigStruct to setup EmbeddedUnionTest.
  ! Ensure values in EmbeddedUnionTest are set correctly for each.
  eut = EmbeddedUnionTest()

  ! First check the SmallStruct in EmbeddedUnionTest
  call eut%set_number(1_C_INT)

  Num1 = eut%get_number()
  if (Num1 /= 1_C_INT) then
    write(0,*) "Runtime test2 failed. eut%number=", Num1
    stop 1
  end if

  print*, "SUCCESS!"

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
