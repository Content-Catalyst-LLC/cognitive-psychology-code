program calibration_overconfidence_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: confidence, accuracy, calibration_error, overconfidence
  real :: cognitive_load, time_pressure, intervention
  real :: cal_sum, over_sum, quality_sum
  real :: u1, u2, u3, u4

  call random_seed()

  cal_sum = 0.0
  over_sum = 0.0
  quality_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     cognitive_load = 10.0 * u1
     time_pressure = 10.0 * u2
     intervention = merge(1.0, 0.0, u3 < 0.5)

     accuracy = logistic(-0.1 + 0.5 - 0.10 * cognitive_load - 0.08 * time_pressure + 0.35 * intervention)
     confidence = accuracy + 0.12 + 0.04 * cognitive_load + 0.03 * time_pressure - 0.12 * intervention + 0.10 * (u4 - 0.5)

     if (confidence < 0.0) confidence = 0.0
     if (confidence > 1.0) confidence = 1.0

     calibration_error = abs(confidence - accuracy)
     overconfidence = confidence - accuracy

     cal_sum = cal_sum + calibration_error
     over_sum = over_sum + overconfidence
     quality_sum = quality_sum + max(0.0, min(1.0, 0.55 + 0.35 * accuracy - 0.25 * calibration_error + 0.08 * intervention))
  end do

  print *, "Calibration and overconfidence model"
  print *, "Trials: ", n
  print *, "Mean calibration error: ", cal_sum / n
  print *, "Mean overconfidence: ", over_sum / n
  print *, "Mean decision quality: ", quality_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program calibration_overconfidence_model
