# This line got modified for some reason...

invalid_character_in_windows_1252 = "\x8D"

      assert_difference ParallelJob, :count, 1 do
        assert_enqueued_jobs 1 do
          assert_enqueued_with(expected_job_attributes) do
          end
        end
      end

      assert_no_difference [Vendor, GlAccount, Property, PayableInvoice, PayableInvoiceDetail, PayablePayment, PayablePaymentDetail, ContactInfo, Address], :count do
        faux_check = Accounting::FauxCheck.new(BankAccount.first)
      end
