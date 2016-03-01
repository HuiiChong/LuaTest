
print(package.path)

require "foo1"

function set_person_name_to_bob(person)
    set_person_name(person, "Bob")
end


print(string.format("file is executed on load : %s",foo1.set_person_name_to_bob()))
