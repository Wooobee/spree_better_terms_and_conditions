Spree::Order.class_eval do

  # attr_accessible :terms_and_conditions # uncomment for Spree below version 2.1

  # Add new checkout step to checkout process
  insert_checkout_step :terms_and_conditions, :before => :confirm

  def valid_terms_and_conditions?
    unless terms_and_conditions == true
      # errors.add(:base, 'Terms and Conditions must be accepted!')
      self.errors[:terms_and_conditions] << Spree.t('terms_and_conditions.must_be_accepted')
      self.errors[:terms_and_conditions].empty? ? true : false
    end
  end
end

# Validate on state change
Spree::Order.state_machine.before_transition :to => :confirm, :do => :valid_terms_and_conditions?

# Add terms_and_conditions to strong parameters
Spree::PermittedAttributes.checkout_attributes << :terms_and_conditions # Remove if Spree is below version 2.1
