module ApplicationHelper

	def digit_to_str(digit)
		digit_hash ={ 0 => "Zero", 1 => "One", 2 => "Two", 3 => "Three",
		             4 => "Four", 5 => "Five", 6 => "Six", 7 => "Seven",
		             8 => "Eight", 9 => "Nine"}
		digit_hash[digit.to_i]
	end
end
