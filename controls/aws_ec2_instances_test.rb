control 'EC2 general compliance test' do
    title 'Compliance tests for AWS EC2 instances'
    desc 'Compliance test using resource aws_ec2_instances'
    
    instance_key = input('instance_key')
    instance_image_id = input('instance_image_id')
    tag = input('tag')
    value = input('value')

    # Ensure you have exactly 3 instances
    describe aws_ec2_instances do
      its('instance_ids.count') { should cmp 3 }
    end

    # Use this InSpec resource to request the IDs of all EC2 instances, then test in-depth using aws_ec2_instance
    aws_ec2_instances.instance_ids.each do |instance_id|
      describe aws_ec2_instance(instance_id) do
        it              { should_not have_roles }
        its('key_name') { should cmp instance_key }
        its('image_id') { should eq instance_image_id }
      end
    end
  
    # Filter EC2 instances with their Environment tags* equal to Dev, then test in-depth using aws_ec2_instance.
    aws_ec2_instances.where(tags: /{tag => value}/).instance_ids.each do |id|
      describe aws_ec2_instance(id) do
        it { should be_stopped }
      end
    end

    # Filter EC2 instances with a stop-at-6-pm tag regardless of its value, then test in-depth using aws_ec2_instance.
    aws_ec2_instances.where(tags: /tag=>/).instance_ids.each do |id|
      describe aws_ec2_instance(id) do
        it { should be_stopped }
      end
    end
  end