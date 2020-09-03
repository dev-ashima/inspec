  control 'EC2 instance compliance test' do
    title 'Compliance tests for AWS EC2 instances'
    desc 'Compliance test using resource aws_ec2_instance'
    
    instances = input('instance_details')

    instances.each do |instance|

      instance_name = instance['name']
      instance_id = instance['id']
      ami_id = instance['AMI']
      tag_name = instance['tag_name']
      tag_value = instance['tag_value']
      role = instance['role']

      # Test for a single AWS EC2 instance by instance id
      describe aws_ec2_instance(instance_id) do
        it { should exist }
      end

      # Test for a single AWS EC2 instance by instance name
      describe aws_ec2_instance(name: instance_name) do
        it { should exist }
      end

      # Test that an EC2 instance is running
      describe aws_ec2_instance(name: instance_name) do
        it { should be_running }
      end

      # Test that an EC2 instance is using the correct AMI
      describe aws_ec2_instance(name: instance_name) do
        its('image_id') { should eq ami_id }
      end

      # Test that an EC2 instance has the correct tag
      describe aws_ec2_instance(instance_id) do
        its('tags') { should include(key: tag_name, value: tag_value) }
      end

      # Test that an EC2 instance has the correct tag (using the tags_hash property)
      describe aws_ec2_instance(instance_id) do
        its('tags_hash') { should include(tag_name => tag_value) }
        its('tags_hash') { should include(tag_name) }                  # Regardless of the value
      end

      # Test that an EC2 instance has no roles
      describe aws_ec2_instance(instance_id) do
        it { should_not have_roles }
      end

      # Filter EC2 instances with their name equal to Test Box, then check their role using aws_ec2_instance.
      aws_ec2_instances.where(name: instance_name).instance_ids.each do |id|
        describe aws_ec2_instance(id) do
          its('role') { should eq role }
        end
      end
    end
  # loop ends 
  end