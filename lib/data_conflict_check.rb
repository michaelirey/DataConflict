module DataConflictCheck

  def get_accessible_attributes
    self.attributes.select { |a| a.in? self.class.accessible_attributes }
  end


  def update_attributes_safe(attributes_to_save, attributes_before_edit)

    # Check to see if record has changed while we were editing
    we_did_not_change = global_changes(attributes_before_edit)

    # Which attributes we have changed
    we_changed = local_changes(attributes_to_save, attributes_before_edit)

    # Check to see if there are any conflicting changes
    conflict_attributes = we_changed & we_did_not_change

    if (conflict_attributes).size > 0 then
      self.errors.add(:data_conflict_error, 
        "You attempted to change the value(s) of #{conflict_attributes.to_sentence}, 
        but the value(s) were changed by someone else while you editing.
        The values have been updated to reflect the latest data")
      return false
    end

    # Only the set the attributes we have changed, otherwise any changes 
    # that are different in self vs attributes_to_save will be saved!
    we_changed.each do |attr|
      self[attr] = attributes_to_save[attr]
    end

    self.save
  end


  private


  # Returns attributes that may have changed elsewhere
  def global_changes(attributes_before_edit)

    # get a copy of the freshest attributes
    fresh_record_attributes = get_accessible_attributes

    # find any differences and return those keys
    (fresh_record_attributes.diff attributes_before_edit).keys
  end


  # Finds the keys of the items we changed during edit
  def local_changes(attributes_to_save, attributes_before_edit)
    (attributes_to_save.diff attributes_before_edit).keys
  end


end