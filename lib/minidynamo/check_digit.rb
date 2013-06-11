# Check digit generator & validator using UPC barcode algorithm
# as described in http://www.gs1.org/barcodes/support/check_digit_calculator


class CheckDigit
	class << self

		def calculate_check_digit(number)
			(10 - (check_sum(number)%10)) % 10
		end

		

		def valid?(number)
			digits = to_digits number
			check = digits.pop
			check == calculate_check_digit(digits)
		end

		private

		def check_sum(number)
			digits = to_digits number
			values = digits.each_slice(2).map do |x, y|
					y ||= 0
					[x*3, y]
				end
			values.flatten.inject(:+)
		end


		def to_digits(number)
			number.to_s.chars.map &:to_i
		end
	end

end