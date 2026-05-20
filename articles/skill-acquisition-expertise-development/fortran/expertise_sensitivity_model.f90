program expertise_sensitivity_model
  implicit none
  integer, parameter :: n = 1000
  integer :: i
  real :: practice, feedback, difficulty, chunking, pattern
  real :: dprime, criterion, correct_probability, false_pattern_probability
  real :: correct_sum, false_sum, dprime_sum
  real :: u1,u2,u3,u4,u5
  call random_seed()
  correct_sum=0.0; false_sum=0.0; dprime_sum=0.0
  do i=1,n
     call random_number(u1); call random_number(u2); call random_number(u3); call random_number(u4); call random_number(u5)
     practice=10*u1; feedback=10*u2; difficulty=10*u3; chunking=10*u4; pattern=10*u5
     dprime=0.7+0.08*practice+0.07*feedback+0.09*chunking+0.10*pattern-0.08*difficulty
     if (dprime < 0.1) dprime=0.1
     criterion=0.55+0.04*difficulty-0.03*feedback-0.03*pattern
     correct_probability=logistic(dprime-criterion)
     false_pattern_probability=logistic(-criterion)
     correct_sum=correct_sum+correct_probability
     false_sum=false_sum+false_pattern_probability
     dprime_sum=dprime_sum+dprime
  end do
  print *, "Expertise sensitivity model"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum/n
  print *, "Mean correct-pattern probability: ", correct_sum/n
  print *, "Mean false-pattern probability: ", false_sum/n
contains
  real function logistic(x)
    real, intent(in) :: x
    logistic=1.0/(1.0+exp(-x))
  end function logistic
end program expertise_sensitivity_model
