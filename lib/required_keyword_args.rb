# Let's you declare a keyword argument as required; will raise an
# ArgumentError if that keyword is omitted. Example:
#
#     def log(message: required('message'), level: LOG_INFO)
def required(arg)
  raise ArgumentError.new("required #{arg}")
end
