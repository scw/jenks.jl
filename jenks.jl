#!/usr/bin/env julia

module Jenks

  type DataClassification
    data::Array{Float64,1}
    n_classes::Int

    function DataClassification(data::Array{Any,1}, n_classes::Int)
      new(convert(Array{Float64,1}, data), n_classes)
    end

    function DataClassification(data::Array{Int,1}, n_classes::Int)
      new(convert(Array{Float64,1}, data), n_classes)
    end

    function DataClassification(data::Array{Float64,1}, n_classes::Int)
      new(data, n_classes)
    end
  end


  function jenks_matrix_init(dc::DataClassification)
    n_data = length(dc.data)
    dims = (n_data + 1, dc.n_classes + 1)

    lower_class_limits  = zeros(dims)
    lower_class_limits[2,2:dc.n_classes+1] = 1.0

    variance_combinations = zeros(dims)
    variance_combinations[3:n_data+1, 2:dc.n_classes+1] = Inf 

    return lower_class_limits, variance_combinations
  end

  function jenks_matrices(dc::DataClassification)
    @inbounds begin
      lower_class_limits, variance_combinations = jenks_matrix_init(dc)
    
      for l in 2:length(dc.data)
        sum = 0.0
        sum_squares = 0.0
        w = 0.0
        variance = 0.0
        for m in 1:l
          # 'III' originally
          lcl = l - m + 1
          val = dc.data[lcl]

          w += 1
          sum += val
          sum_squares += val*val

          variance = sum_squares - (sum*sum) / w
          if lcl != 1
            for j in 2:dc.n_classes
              var_plus_prev = variance + variance_combinations[lcl, j]
              if variance_combinations[l+1, j+1] >= var_plus_prev
                lower_class_limits[l+1, j+1] = lcl
                variance_combinations[l+1, j+1] = var_plus_prev
              end
            end
          end
        end
        lower_class_limits[l+1,2] = 1.0
        variance_combinations[l+1,2] = variance
      end
    end
    return lower_class_limits, variance_combinations
  end

  function jenks(data, n_classes)
    dc = Jenks.DataClassification(data, n_classes)
    if dc.n_classes > length(dc.data)
      return
    end

    sort!(dc.data)

    lower_class_limits, variance_combinations = jenks_matrices(dc)

    k = length(dc.data)
    count_num = dc.n_classes

    classification = zeros(dc.n_classes+1)
    classification[dc.n_classes+1] = dc.data[k]
    classification[1] = dc.data[1]

    for count_num=dc.n_classes:-1:2
      elt = int(lower_class_limits[k,count_num+1] - 1)
      classification[count_num] = dc.data[elt]
      k = int(lower_class_limits[k,count_num+1])
    end

    return classification
  end
end
