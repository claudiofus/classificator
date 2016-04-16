package com.gruppoicse.beleaf.beleaf.entity;

import java.io.Serializable;
import java.util.Random;
import jess.Activation;
import jess.Strategy;

public final class RandomActivation implements Strategy, Serializable {
	private static final long serialVersionUID = 1L;
	private static final String mName = "RandomActivation";
	private final Random mGenerator;

	public RandomActivation() {
		mGenerator = new Random();
	}

	public final int compare(final Activation pAct1, final Activation pAct2) {
		int result;

		final double r1 = mGenerator.nextDouble();
		final double r2 = mGenerator.nextDouble();
		if (pAct1.getSalience() < pAct2.getSalience()) {
			result = 1;
		}
		else if (pAct1.getSalience() > pAct2.getSalience()) {
			result = -1;
		}
		else {
			if (r1 < r2) {
				result = 1;
			} else if (r1 > r2) {
				result = -1;
			} else {
				result = 0;
			}
		}
		return result;
	}

	public final String getName() {
		return mName;
	}
}