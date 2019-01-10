package com.reactlibrary;

import android.content.Intent;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.android.gms.common.util.ArrayUtils;

import static com.reactlibrary.RNOnfidoSdkModule.REQUEST_CODE_DOCUMENT_TYPE;


public class OnfidoCustomDocumentTypesActivity extends AppCompatActivity {

    private View.OnClickListener getOnclickListener(final int documentType) {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent returnIntent = new Intent();
                returnIntent.putExtra("documentType", documentType);
                setResult(REQUEST_CODE_DOCUMENT_TYPE, returnIntent);
                finish();
            }
        };
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        int[] documentTypes = intent.getIntArrayExtra("documentTypes");

        setContentView(R.layout.activity_custom_documents);

        View buttonPassportView = findViewById(R.id.button_passport);
        TextView buttonPassportTextView = buttonPassportView.findViewById(R.id.documentTypeLabel);
        buttonPassportTextView.setText(R.string.passport);
        ImageView passportImageView = buttonPassportView.findViewById(R.id.imageView);
        passportImageView.setImageResource(R.drawable.onfido_passport);
        int passportVisibility = ArrayUtils.contains(documentTypes, 0) ? View.VISIBLE : View.GONE;
        buttonPassportView.setVisibility(passportVisibility);
        buttonPassportView.setOnClickListener(getOnclickListener(0));

        View buttonDriverLicenceView = findViewById(R.id.button_driver_license);
        TextView buttonDriverLicenceTextView = buttonDriverLicenceView.findViewById(R.id.documentTypeLabel);
        buttonDriverLicenceTextView.setText(R.string.driver_licence);
        ImageView driverLicenceImageView = buttonDriverLicenceView.findViewById(R.id.imageView);
        driverLicenceImageView.setImageResource(R.drawable.onfido_driving_licence);
        int driverLicenceVisibility = ArrayUtils.contains(documentTypes, 1) ? View.VISIBLE : View.GONE;
        buttonDriverLicenceView.setVisibility(driverLicenceVisibility);
        buttonDriverLicenceView.setOnClickListener(getOnclickListener(1));

        View buttonNationalIdentityCardView = findViewById(R.id.button_national_identity_card);
        TextView buttonNationalIdentityCardTextView = buttonNationalIdentityCardView.findViewById(R.id.documentTypeLabel);
        buttonNationalIdentityCardTextView.setText(R.string.national_identity_card);
        ImageView nationalIdentityCardImageView = buttonNationalIdentityCardView.findViewById(R.id.imageView);
        nationalIdentityCardImageView.setImageResource(R.drawable.onfido_national_id);
        int nationalIdVisibility = ArrayUtils.contains(documentTypes, 2) ? View.VISIBLE : View.GONE;
        buttonNationalIdentityCardView.setVisibility(nationalIdVisibility);
        buttonNationalIdentityCardView.setOnClickListener(getOnclickListener(2));

        View buttonResidencePermitCardView = findViewById(R.id.button_residence_permit_card);
        TextView buttonResidencePermitCardTextView = buttonResidencePermitCardView.findViewById(R.id.documentTypeLabel);
        buttonResidencePermitCardTextView.setText(R.string.residence_permit);
        ImageView residencePermitCardImageView = buttonResidencePermitCardView.findViewById(R.id.imageView);
        residencePermitCardImageView.setImageResource(R.drawable.onfido_ic_residence_card);
        int residenceCardVisibility = ArrayUtils.contains(documentTypes, 3) ? View.VISIBLE : View.GONE;
        buttonResidencePermitCardView.setVisibility(residenceCardVisibility);
        buttonResidencePermitCardView.setOnClickListener(getOnclickListener(3));
    }
}
