new_post:
	hugo new --kind '$(kind)' '$(kind)/$(name).md'

startd:
	hugo server -D

start:
	hugo server