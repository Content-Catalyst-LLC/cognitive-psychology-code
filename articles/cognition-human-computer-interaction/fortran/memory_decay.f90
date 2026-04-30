program memory_decay
  implicit none
  integer :: t
  real :: memory_strength
  real, parameter :: decay_rate = 0.12

  memory_strength = 1.0

  do t = 1, 10
     memory_strength = memory_strength * exp(-decay_rate)
     print *, t, memory_strength
  end do
end program memory_decay
