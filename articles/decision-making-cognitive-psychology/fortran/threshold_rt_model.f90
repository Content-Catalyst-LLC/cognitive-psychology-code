program threshold_rt_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: evidence, uncertainty, time_pressure, threshold, drift
  real :: accuracy, rt, quality
  real :: acc_sum, rt_sum, quality_sum
  real :: u1, u2, u3

  call random_seed()

  acc_sum = 0.0
  rt_sum = 0.0
  quality_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)

     evidence = -3.0 + 6.0 * u1
     uncertainty = 10.0 * u2
     time_pressure = 10.0 * u3
     threshold = max(0.45, min(2.5, 1.2 + 0.08 * uncertainty - 0.06 * time_pressure))
     drift = 0.32 * evidence - 0.04 * uncertainty

     accuracy = logistic(-0.2 + 1.4 * abs(drift) + 0.35 * threshold - 0.08 * time_pressure)
     rt = exp(log(2.0) + 0.40 * threshold - 0.25 * abs(drift) + 0.03 * uncertainty - 0.04 * time_pressure)
     quality = max(0.0, min(1.0, 0.30 + 0.55 * accuracy - 0.04 * uncertainty + 0.02 * threshold))

     acc_sum = acc_sum + accuracy
     rt_sum = rt_sum + rt
     quality_sum = quality_sum + quality
  end do

  print *, "Threshold and response-time model"
  print *, "Trials: ", n
  print *, "Mean accuracy: ", acc_sum / n
  print *, "Mean response time: ", rt_sum / n
  print *, "Mean decision quality: ", quality_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program threshold_rt_model
