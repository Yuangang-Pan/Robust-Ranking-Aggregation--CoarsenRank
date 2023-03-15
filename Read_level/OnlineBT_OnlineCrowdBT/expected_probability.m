function R_abc = expected_probability(mu, sigma, i, j, l, S)

delta = sum( exp( mu( S( i:l ) ) ) );

part_a = exp(mu(S(j))) / delta;
part_b = (delta - 2*exp(mu(S(j)))) / delta;


part1 = part_a;
part2 = 1/2 * sigma(S(j)) * part_a * part_b;

part3 = 0;
for k = i:l
    part3 = part3 + 1/2 * sigma(S(k)) * part_a * part_b * exp(mu(S(k))) / delta;
end
    R_abc = part1 + part2 - part3;
end