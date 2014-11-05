Spree::Order.class_eval do

  # attr_accessible :terms_and_conditions # uncomment for Spree below version 2.1
  
  checkout_flow do
    go_to_state :address
    go_to_state :delivery
    go_to_state :payment, if: ->(order) {
    order.update_totals
    order.payment_required?
    }
    go_to_state :terms_and_conditions
    go_to_state :confirm, if: ->(order) { order.confirmation_required? }
    go_to_state :complete
  end

  # If true, causes the payment step to happen during the checkout process
  def payment_required?
    return true
  end

  # If true, causes the confirmation step to happen during the checkout process
  def confirmation_required?
    return true
  end

  # Add new checkout step to checkout process
  #insert_checkout_step :terms_and_conditions, :before => :confirm

  def valid_terms_and_conditions?
    logger.debug "Terms and Conditions: #{terms_and_conditions}"
    unless terms_and_conditions == true
      errors.add(:base, 'Terms and Conditions must be accepted!')
      
      self.errors[:terms_and_conditions] << Spree.t('terms_and_conditions.must_be_accepted')
      if self.errors[:terms_and_conditions].empty?
        return true
      else
        logger.debug "Not checked! Dont move"
        return false
      end
      #self.errors[:terms_and_conditions].empty? ? return true : return false
      logger.debug "Terms checked: #{self.errors[:terms_and_conditions]}"
    end
  end
end


# Validate on state change
Spree::Order.state_machine.before_transition :to => :confirm, :do => :valid_terms_and_conditions?

# Add terms_and_conditions to strong parameters
Spree::PermittedAttributes.checkout_attributes << :terms_and_conditions # Remove if Spree is below version 2.1
