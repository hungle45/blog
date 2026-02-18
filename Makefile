new_kind:
	hugo new --kind '$(kind)' '$(kind)/$(name).md'

new:
	hugo new '$(kind)/$(name).md'

startd:
	hugo server -D

start:
	hugo server